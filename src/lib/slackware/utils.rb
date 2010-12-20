#!/usr/bin/env ruby 
# started - Fri Oct	9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010
# Copyright 2009, 2010 Vincent Batts, http://hashbangbash.com/

require 'slackware'

# Variables
@st = "\033[31;1m"
@en = "\033[0m"

# Classes


# Functions
def build_packages(opts = {}, args = [])
	pkgs = Slackware::System.installed_packages
	
	if (opts[:time])
		pkgs = pkgs.each {|p| p.get_time }
	end
	if (opts[:all])
		if (args.count > 0)
			selected_pkgs = []
			args.each {|arg|
				pkgs.each {|pkg|
					if pkg.fullname =~ /#{arg}/
						selected_pkgs << pkg
					end
				}
			}
			pkgs = selected_pkgs.uniq
			selected_pkgs = nil
		end
	end
	if (opts[:pkg_given])
		pkgs = pkgs.map {|p|
			re = /#{opts[:pkg]}/i
			if p.name =~ re
				if (opts[:color])
					p.name = p.name.gsub(re, "#{@st}\\&#{@en}")
				end
				p
			end
		}.compact
	end
	if (opts[:Version_given])
		pkgs = pkgs.map {|p|
			re = Regexp.new(Regexp.escape(opts[:Version]))
			if p.version =~ re
				if (opts[:color])
					p.version = p.version.gsub(re, "#{@st}\\&#{@en}")
				end
				p
			end
		}.compact
	end
	if (opts[:arch_given])
		pkgs = pkgs.map {|p|
			re = /#{opts[:arch]}/
			if p.arch =~ re
				if (opts[:color])
					p.arch = p.arch.gsub(re, "#{@st}\\&#{@en}")
				end
				p
			end
		}.compact
	end
	if (opts[:build_given])
		pkgs = pkgs.map {|p|
			re = /#{opts[:build]}/
			if p.build =~ re
				if (opts[:color])
					p.build = p.build.gsub(re, "#{@st}\\&#{@en}")
				end
				p
			end
		}.compact
	end
	if (opts[:tag_given])
		pkgs = pkgs.map {|p|
			re = /#{opts[:tag]}/i
			if p.tag =~ re
				if (opts[:color])
					p.tag = p.tag.gsub(re, "#{@st}\\&#{@en}")
				end
				p
			end
		}.compact
	end

	return pkgs
end

def print_packages(pkgs)
	if (pkgs.count > 0 && pkgs.first.class == Slackware::Package)
		pkgs.each {|pkg|
			printf("%s\n", pkg.fullname )
		}
	end
end

def print_packages_times(pkgs, epoch = false)
	if (epoch == true)
		pkgs.each {|pkg| printf("%s : %s\n", pkg.fullname, pkg.time.to_i) }
	else
		pkgs.each {|pkg| printf("%s : %s\n", pkg.fullname, pkg.time.to_s) }
	end
end

# package file listing
def print_package_file_list(pkgs)
	if (pkgs.count > 1)
		pkgs.each {|pkg|
			pkg.get_owned_files.each {|line|
				puts pkg.name + ": " + line
			}
		}
	else
		pkgs.each {|pkg| puts pkg.get_owned_files }
	end
end

# search Array of Slackware::Package's for files
# and print the items found
def print_package_searched_files(pkgs, files)
	found_files = []
	files.each {|file|
		found_files = found_files.concat(Slackware::System.owns_file(file))
	}
	found_files.each {|file|
		puts file[0].fullname + ": " + file[1]
	}
end

# find orpaned files from /etc/
# 	* build a list of files from removed_packages
# 	* check the list to see if they are currently owned by a package
# 	* check the unowned members, to see if they still exist on the filesystem
# 	* return existing files
def find_orphaned_config_files
	# build a list of config files currently installed
	installed_config_files = Slackware::System.installed_packages.map {|pkg|
		pkg.get_owned_files.map {|file|
			file if (file =~ /^etc\// && not(file =~ /\/$/))
		}
	}.flatten.compact

	# this Array is where we'll stash removed packages that have config file to check
	pkgs = Array.new
	Slackware::System.removed_packages.each {|r_pkg|
		# find config files for this removed package
		config = r_pkg.get_owned_files.grep(/^etc\/.*[\w|\d]$/)
		# continue if there are none
		if (config.count > 0)
			# remove config files that are owned by a currently installed package
			config = config.map {|file|
				if (not(installed_config_files.include?(file)) && not(installed_config_files.include?(file + ".new")))
					file
				end
			}.compact
			# check again, and continue if there are no config files left
			if (config.count > 0)
				# otherwise add this package, and its files, to the stack
				pkgs << {:pkg => r_pkg, :files => config}
			end
		end
	}

	# setup list of files to check whether they still exist on the filesystem
	files = []
	pkgs.map {|pkg| files << pkg[:files] }
	files.flatten!.uniq!

	orphaned_config_files = []
	files.each {|file|
		if (File.exist?("/" + file))
			orphaned_config_files << file
		end
	}

	return orphaned_config_files

end

def print_orphaned_files(files)
	puts files
end

# XXX This is a work in progress
# It _works_, but is pretty darn slow ...
# It would be more efficient to break this out to a separate Class,
# and use a sqlite database for caching linked dependencies.
# Categorized by pkg, file, links. based on mtime of the package file, 
# or maybe even mtime of the shared objects themselves.
# That way, those entries alone could be updated if they are newer,
# otherwise it's just a query.
def find_linked(file_to_find)
	require 'find'

	dirs = %w{ /lib /lib64 /usr/lib /usr/lib64 /bin /sbin /usr/bin /usr/sbin }
	re_so = Regexp.new(/ELF.*shared object/)
	re_exec = Regexp.new(/ELF.*executable/)

	if File.exist?(file_to_find)
		file_to_find = File.expand_path(file_to_find)
	end
	if not(filemagic(File.dirname(file_to_find) + "/" + File.readlink(file_to_find)) =~ re_so)
		printf("%s is not a shared object\n",file_to_find)
		return nil
	end

	includes_linked = []
	printf("Searching through ... ")
	dirs.each {|dir|
		printf("%s ", dir)
		Find.find(dir) {|file|
			if File.directory?(file)
				next
			end
			file_magic = filemagic(file)
			if (file_magic =~ re_so || file_magic =~ re_exec)
				l = `/usr/bin/ldd #{file} 2>/dev/null `
				if l.include?(file_to_find)
					printf(".")
					l = l.sub(/\t/, '').split(/\n/)
					includes_linked << {:file => file, :links => l}
				end
			end
		}
	}
	printf("\n")
	return includes_linked
end

# This is intended to take the return of the find_linked() method
def packages_of_linked_files(linked_files_arr)
	pkgs = Slackware::System.installed_packages
	owned_pkgs = []
	pkgs.map {|pkg|
		files.each {|file|
			if pkg.owned_files.include?(file)
				owned_pkgs << {:pkg => pkg, :file => file}
			end
		}
	}
	return owned_pkgs
end

# Pretty print the output of find_linked()
def print_find_linked(file_to_find)
	files = find_linked(file_to_find)
	printf("files linked to '%s' include:\n", file_to_find)
	files.each {|file|
		printf("  %s\n", file)
	}
end

private

def filemagic(file)
	return `/usr/bin/file "#{file}"`.chomp
end

