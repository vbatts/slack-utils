#!/usr/bin/env ruby 
# started - Fri Oct	9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010
# Copyright 2009, 2010 Vincent Batts, http://hashbangbash.com/

# Variables
@installed_packages_dir = '/var/log/packages' # TODO this should be put to a conf file at some point
@removed_packages_dir = '/var/log/removed_packages/' # TODO this should be put to a conf file at some point
@packages_array = Dir.entries(@installed_packages_dir)
@me = File.basename($0)
#@st = "\033[31;1m" # TODO These should be put to a flag at some point
#@en = "\033[0m"

# Classes
class Slackware
	VERSION = "13.1"
	attr_accessor :name, :time, :path, :file
	def initialize
		@name = @file = @path = @time = ""
	end
end

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

def slp
	if ARGV.count == 0
		@packages_array.each {|pkg|
			puts pkg
		}
	else
		ARGV.each {|arg|
			puts @packages_array.grep(/#{arg}/)
		}
	end
end

def slt
	if ARGV.count == 0
		@packages_array.each {|pkg|
			file_time = File.mtime(sl_path(pkg))
			puts "#{pkg}:\s#{file_time}"
		}
	else
		ARGV.each {|arg|
			@packages_array.grep(/#{arg}/).each {|pkg|
				next if is_sl_pd?(sl_path(pkg))
				file_time = File.mtime(sl_path(pkg))
				puts "#{pkg}:\s#{file_time}"
			}
		}
	end
end

def slf
	require 'iconv' # XXX putting this here, since it is only used in this method


	if ARGV.count == 0
		puts "#{@me}: what file do you want me to search for?"
	else
		ARGV.each {|arg|
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
def sll
	if ARGV.count == 0
		puts "#{@me}: what package do you want to list?"
	else
		ARGV.each {|arg|
			@packages_array.grep(/#{arg}/).each {|pkg|
				p = sl_path(pkg)
				next if is_sl_pd?(p)
				system("tail +$(expr $(grep -n ^FILE #{p} | cut -d : -f 1 ) + 2) #{p} ")
			}
		}
	end
end

# XXX stub for slack-utils orpaned .new files (to be written in ruby)
def slo
	new_pat = Regexp.new(/\.new$/)
	removed_packages_array = Dir.entries(@removed_packages_dir)
	removed_packages_array.each {|pkg|
		file_path = File.absolute_path(File.join(@removed_packages_dir, '/', pkg))
		if (file_path == @removed_packages_dir || file_path == "/var/log" || file_path == "/var/log/removed_packages")
			next
		end
		file = File.open(file_path)
		file.each {|line|
			puts line if new_pat.match(line)
		}
	}
end

