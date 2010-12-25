
require 'slackware/version'
require 'slackware/package'

module Slackware
	DIR_INSTALLED_PACKAGES = "/var/log/packages"
	DIR_REMOVED_PACKAGES = "/var/log/removed_packages"
	DIR_INSTALLED_SCRIPTS = "/var/log/scripts"
	DIR_REMOVED_SCRIPTS = "/var/log/removed_scripts"
	RE_REMOVED_NAMES = /^(.*)-upgraded-(\d{4}-\d{2}-\d{2}),(\d{2}:\d{2}:\d{2})$/
	RE_BUILD_TAG = /^([[:digit:]]+)([[:alpha:]]+)$/

	def self::version
		Slackware::VERSION
	end

	class System

		def self::installed_packages
			return Dir.glob(DIR_INSTALLED_PACKAGES + "/*").sort.map {|p| Slackware::Package.parse(p) }
		end

		def self::removed_packages
			return Dir.glob(DIR_REMOVED_PACKAGES + "/*").sort.map {|p| Slackware::Package.parse(p) }
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
			pkgs = installed_packages
			found_files = []
			file = file.sub(/^\//, "") # clean off the leading '/'
			re = Regexp::new(/#{file}/)
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
			Slackware::VERSION
		end
	end

end

