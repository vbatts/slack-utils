
require 'time'

module Slackware
	VERSION = begin
			  data = File.read("/etc/slackware-version")
			  data =~ /Slackware\s(.*)/
			  $1
		  rescue
			  nil
		  end

	DIR_INSTALLED_PACKAGES = "/var/log/packages"
	DIR_REMOVED_PACKAGES = "/var/log/removed_packages"
	DIR_INSTALLED_SCRIPTS = "/var/log/scripts"
	DIR_REMOVED_SCRIPTS = "/var/log/removed_scripts"
	RE_REMOVED_NAMES = /^(.*)-upgraded-(\d{4}-\d{2}-\d{2}),(\d{2}:\d{2}:\d{2})$/
	RE_BUILD_TAG = /^([[:digit:]]+)([[:alpha:]]+)$/

	def self::version
		VERSION
	end

	class Package
		attr_accessor :time,
			:path,
			:file,
			:name,
			:version,
			:arch,
			:build,
			:tag,
			:tag_sep,
			:upgrade_time,
			:owned_files

		def initialize(name = nil)
			self.name = name
			@package_description = @package_location = @compressed_size = @uncompressed_size = nil
			return self
		end

		# pkg.parse instance method for parsing the package information
		def parse(name)
			if name.include?("/")
				self.path = File.dirname(name)
				name = File.basename(name)
			end
			if (name =~ RE_REMOVED_NAMES)
				name = $1
				self.upgrade_time = Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S')
			end
			arr = name.split('-').reverse
			build = arr.shift
			if (build.include?("_"))
				self.tag_sep = "_"
				self.build = build.split(self.tag_sep)[0]
				self.tag = build.split(self.tag_sep)[1..-1].join(self.tag_sep)
			elsif (build =~ RE_BUILD_TAG)
				self.build = $1
				self.tag = $2
			else
				self.build = build
			end
			self.arch = arr.shift
			self.version = arr.shift
			self.name = arr.reverse.join('-')
		end

		# Package.parse class method
		def self::parse(name)
			p = self.new()
			p.parse(name)
			return p
		end
		
		# Reassemble the package name as it would be in file form
		def fullname
			if (self.upgrade_time)
				time = self.upgrade_time.strftime("%F,%H:%M:%S")
				return [self.name, self.version, self.arch, [self.build, self.tag].join(self.tag_sep), "upgraded", time].join("-")
			else
				return [self.name, self.version, self.arch, [self.build, self.tag].join(self.tag_sep)].join("-")
			end
		end

		# Accessor for the PACKAGE DESCRIPTION from the package file
		def package_description
			if not(@package_description.nil?)
				return @package_description
			end

			f = File.open(self.path + '/' + self.fullname)
			while true
				if (f.readline =~ /^PACKAGE DESCRIPTION:\s+(.*)$/)
					desc = f.take_while {|l| not(l =~ /FILE LIST:/) }.map {|l| l.sub(/^#{self.name}:\s*/, '').chomp }
					return desc
				end
			end
		end

		# Setter for the PACKAGE DESCRIPTION, in the event you are parsing a repo file
		def package_description=(desc)
			@package_description = desc
		end

		# Accessor for the PACKAGE LOCATION from the package file
		def package_location
			if not(@package_location.nil?)
				return @package_location
			end

			f = File.open(self.path + '/' + self.fullname)
			while true
				if (f.readline =~ /^PACKAGE LOCATION:\s+(.*)$/)
					return $1
				end
			end
		end

		# Setter for the PACKAGE LOCATION, in the event you are parsing a repo file
		def package_location=(path)
			@package_location = path
		end

		# Accessor for the UNCOMPRESSED PACKAGE SIZE from the package file
		def uncompressed_size
			if not(@uncompressed_size.nil?)
				return @uncompressed_size
			end

			f = File.open(self.path + '/' + self.fullname)
			while true
				if (f.readline =~ /^UNCOMPRESSED PACKAGE SIZE:\s+(.*)$/)
					return $1
				end
			end
		end

		# Setter for the UNCOMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
		def uncompressed_size=(size)
			@uncompressed_size = size
		end

		# Accessor for the COMPRESSED PACKAGE SIZE from the package file
		def compressed_size
			if not(@compressed_size.nil?)
				return @compressed_size
			end

			f = File.open(self.path + '/' + self.fullname)
			while true
				if (f.readline =~ /^COMPRESSED PACKAGE SIZE:\s+(.*)$/)
					return $1
				end
			end
		end

		# Setter for the COMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
		def compressed_size=(size)
			@compressed_size = size
		end

		# Accessor for the FILE LIST from the package file
		# unless the :owned_files symbol is populated
		def get_owned_files
			if not(self.owned_files.nil?)
				return self.owned_files
			else
				f = File.open(self.path + '/' + self.fullname)
				files = f.drop_while {|l| not( l =~ /^FILE LIST:/) }[2..-1].map {|l| l.chomp }
				f.close
				return files
			end
		end

		# Set the file list in the package object in memory
		def set_owned_files
			if self.owned_files.nil?
				self.owned_files = self.get_owned_files
				return true
			else
				return false
			end
		end

		# populates and returns self.time
		def get_time
			if (self.time.nil? && self.path)
				if (File.exist?(self.path + "/" + self.fullname))
					self.time = File.mtime(self.path + "/" + self.fullname)
				end
			elsif (self.time.nil? && not(self.path))
				if (File.exist?(DIR_INSTALLED_PACKAGES + "/" + self.fullname))
					self.time = File.mtime(DIR_INSTALLED_PACKAGES + "/" + self.fullname)
				end
			end
			return self.time
		end

		# Fill in the path information
		def get_path
			if (self.path.nil? && File.exist?(DIR_INSTALLED_PACKAGES + "/" + self.name))
				self.path = DIR_INSTALLED_PACKAGE
				return DIR_INSTALLED_PACKAGE
			end
		end

	end

	class Script < Package
		attr_accessor :script

		def initialize(name = nil)
			self.script = true
			super
		end

		def parse(name)
			super
			self.script = true
		end

	end

	class System

		def self::installed_packages
			return Dir.glob(DIR_INSTALLED_PACKAGES + "/*").sort.map {|p| Package.parse(p) }
		end

		def self::removed_packages
			return Dir.glob(DIR_REMOVED_PACKAGES + "/*").sort.map {|p| Package.parse(p) }
		end

		def self::installed_scripts
			return Dir.glob(DIR_INSTALLED_SCRIPTS + "/*").sort.map {|s| Script.parse(s) }
		end

		def self::removed_scripts
			return Dir.glob(DIR_REMOVED_SCRIPTS + "/*").sort.map {|s| Script.parse(s) }
		end

		def self::tags_used
			return installed_packages.map {|p| p.tag }.uniq.compact
		end

		def self::with_tag(tag)
			return installed_packages.map {|pkg| pkg if pkg.tag == tag }.compact
		end

		def self::arch_used
			return installed_packages.map {|p| p.arch }.uniq.compact
		end

		def self::with_arch(arch)
			return installed_packages.map {|pkg| pkg if pkg.arch == arch }.compact
		end

		def self::find_installed(name)
			d = Dir.new(DIR_INSTALLED_PACKAGES)
			return d.map {|p| Package.parse(p) if p.include?(name) }.compact
		end

		def self::find_removed(name)
			d = Dir.new(DIR_REMOVED_PACKAGES)
			return d.map {|p| Package.parse(p) if p.include?(name) }.compact
		end

		def self::upgrades(pkg)
			if (m = find_removed(pkg).map {|p| p if (p.name == pkg) }.compact )
				return m
			else
				return nil
			end
		end

		# Return an Array of packages, that were installed after provided +time+
		def self::installed_after(time)
			arr = []
			di = Dir.new(DIR_INSTALLED_PACKAGES)
			di.each {|p|
				if (File.mtime(DIR_INSTALLED_PACKAGES + "/" + p) >= time)
					pkg = Package.parse(p)
					pkg.get_time
					arr << pkg
				end
			}
			return arr
		end

		# Return an Array of packages, that were installed before provided +time+
		def self::installed_before(time)
			arr = []
			di = Dir.new(DIR_INSTALLED_PACKAGES)
			di.each {|p|
				if (File.mtime(DIR_INSTALLED_PACKAGES + "/" + p) <= time)
					pkg = Package.parse(p)
					pkg.get_time
					arr << pkg
				end
			}
			return arr
		end

		# Return an Array of packages, that were removed after provided +time+
		def self::removed_after(time)
			arr = []
			dr = Dir.new(DIR_REMOVED_PACKAGES)
			dr.each {|p|
				if (DIR_INSTALLED_PACKAGES + "/" + p =~ RE_REMOVED_NAMES)
					if (Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S') >= time)
						arr << Package.parse(p)
					end
				end
			}
			return arr
		end

		# Return an Array of packages, that were removed before provided +time+
		def self::removed_before(time)
			arr = []
			dr = Dir.new(DIR_REMOVED_PACKAGES)
			dr.each {|p|
				if (DIR_INSTALLED_PACKAGES + "/" + p =~ RE_REMOVED_NAMES)
					if (Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S') <= time)
						arr << Package.parse(p)
					end
				end
			}
			return arr
		end

		# Check whether a given Slackware::Package has been upgraded before
		def self::is_upgraded?(pkg)
			if (find_removed(pkg).map {|p| p.name if p.upgrade_time }.include?(pkg) )
				return true
			else
				return false
			end
		end

		# Search installation of Slackware::Package's for what owns the questioned file
		def self::owns_file(file)
			file = file.sub(/^\//, "") # clean off the leading '/'
			re = Regexp::new(/#{file}/)
			pkgs = installed_packages
			found_files = []
			pkgs.each {|pkg|
				if (found = pkg.get_owned_files.map {|f| f if f =~ re}.compact)
					found.each {|f|
						found_files << [pkg, f]
					}
				end
			}
			return found_files
		end

		# Return the version of Slackware Linux currently installed
		def self::version
			VERSION
		end
	end

end

