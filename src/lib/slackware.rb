
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

	class Package
		attr_accessor :fullname, :time, :path, :file, :name, :version, :arch, :build, :tag, :upgrade_time
		def initialize(name = nil)
			self.name = name
		end

		def parse(name)
			if name.include?("/")
				self.path = File.dirname(name)
				name = File.basename(name)
			end
			if (name =~ RE_REMOVED_NAMES)
				name = $1
				self.upgrade_time = Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S')
			end
			self.fullname = name
			arr = name.split('-').reverse
			build = arr.shift
			if (build.include?("_"))
				self.build = build.split("_")[0]
				self.tag = build.split("_")[1..-1].join("_")
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

		def self::parse(name)
			p = self.new()
			p.parse(name)
			return p
		end
		
		def get_time
			if (self.time.nil? && self.path)
				if (File.exist?(self.path + "/" + self.name))
					self.time = File.mtime(self.path + "/" + self.name)
				end
			elsif (self.time.nil? && not(self.path))
				if (File.exist?(DIR_INSTALLED_PACKAGES + "/" + self.name))
					self.time = File.mtime(DIR_INSTALLED_PACKAGESself + "/" + self.name)
				end
			end
			return self.time
		end

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

	def self::upgrades(pkg)
		if (m = removed_packages.map {|p| p if (p.name == pkg) }.compact )
			return m
		else
			return nil
		end
	end

	def self::is_upgraded?(pkg)
		if (removed_packages.map {|p| p.name if p.upgrade_time }.include?(pkg) )
			return true
		else
			return false
		end
	end

	def self::version
		VERSION
	end

end

