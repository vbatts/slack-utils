#!/usr/bin/env ruby 
# started - Fri Oct	9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010
# Copyright 2009, 2010 Vincent Batts, http://hashbangbash.com/

require 'slackware'

# Variables
@installed_packages_dir = '/var/log/packages' # TODO this should be put to a conf file at some point
@removed_packages_dir = '/var/log/removed_packages/' # TODO this should be put to a conf file at some point
@packages_array = begin
			  Dir.entries(@installed_packages_dir).sort.map {|p|
				  pkg = []
				  p.split("-")
			  }
end
@me = File.basename($0)
#@st = "\033[31;1m" # TODO These should be put to a flag at some point
#@en = "\033[0m"

# Classes
# Functions
def sl_path(package)
	File.absolute_path(File.join(@installed_packages_dir, '/', package))
end

def is_sl_pd?(some_path)
	if (some_path == @installed_packages_dir || some_path == "/var/log")
		true
	else
		false
	end
end

def call_func(meth, *args)
	methods = %w{ slo slp slt sll slf }
	if (methods.include?(meth))
		eval("#{meth} #{args}")
	else
		raise StandError.new("#{meth} method not found")
	end
end

def slp(*args)
	pkgs = Slackware.installed_packages
	if args.count == 0
		pkgs.each {|pkg| printf("%s %s %s %s\n", pkg.name, pkg.version, pkg.arch, pkg.build ) }
	else
		args.each {|arg|
			puts @packages_array.grep(/#{arg}/)
		}
	end
end

def slt(*args)
	if args[0].count == 0
		@packages_array.each {|pkg|
			file_time = File.mtime(sl_path(pkg))
			puts "#{pkg}:\s#{file_time}"
		}
	else
		args[0].each {|arg|
			@packages_array.grep(/#{arg}/).each {|pkg|
				next if is_sl_pd?(sl_path(pkg))
				file_time = File.mtime(sl_path(pkg))
				puts "#{pkg}:\s#{file_time}"
			}
		}
	end
end

def slf(*args)
	require 'iconv' # XXX putting this here, since it is only used in this method

	if args[0].count == 0
		puts "#{@me}: what file do you want me to search for?"
	else
		args[0].each {|arg|
			new_arg = arg.gsub(/^\//, "") # clean off the leading '/'
			re_arg = Regexp::new(/#{new_arg}/)
			ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
			@packages_array.each {|pkg|
				p = sl_path(pkg)
				next if is_sl_pd?(p)
				f = File.open(p)
				f.each {|line|
					## TODO needs a flag, to be colorized
					#o = line.gsub! re_arg, "#{@st}\\&#{@en}"
					#puts pkg + ":\s" + o if ! o.nil?

					## craziness to workaround "invalid byte sequence in UTF-8"
					## http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/
					clean_line = ic.iconv(line + "  ")[0..-2]
					puts pkg + ":\s" + line if re_arg.match(clean_line)
				}
			}
		}
	end
end

# package file listing
# TODO re-write in pure ruby :\
def sll(*args)
	if args[0].count == 0
		puts "#{@me}: what package do you want to list?"
	else
		args[0].each {|arg|
			@packages_array.grep(/#{arg}/).each {|pkg|
				p = sl_path(pkg)
				next if is_sl_pd?(p)
				system("tail +$(expr $(grep -n ^FILE #{p} | cut -d : -f 1 ) + 2) #{p} ")
			}
		}
	end
end

# XXX stub for slack-utils orpaned .new files (to be written in ruby)
# TODO
# 	* check the members of the new_files array, to see if they are currently owned by a package
# 	* check the unowned members, to see if they still exist
# 	* build a Hash for each *.new file, that 
def slo
	new_pat = Regexp.new(/\.new$/)
	new_files = Array.new
	removed_packages_array = Dir.entries(@removed_packages_dir)

	removed_packages_array.each {|pkg|
		file_path = File.absolute_path(File.join(@removed_packages_dir, '/', pkg))
		if (file_path == @removed_packages_dir ||
		    file_path == "/var/log" ||
		    file_path == "/var/log/removed_packages"
		   )
			next
		end
		file = File.open(file_path)
		file.each_line {|line|
			new_files << line.chomp if new_pat.match(line)
		}
	}

	new_files.sort!.uniq!
	#@new_files.each {|f| puts f }
	return new_files

end

