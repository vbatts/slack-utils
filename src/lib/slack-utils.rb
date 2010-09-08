#!/usr/bin/env ruby 
# started - Fri Oct	9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010
# Copyright 2009, 2010 Vincent Batts, http://hashbangbash.com/

# Variables
@pd = '/var/log/packages' # TODO this should be put to a conf file at some point
@pa = Dir.entries(@pd)
@me = File.basename($0)
@st = "\033[31;1m" # TODO These should be put to a flag at some point
@en = "\033[0m"

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
	File.absolute_path(File.join(@pd, '/', package))
end

def is_sl_pd?(some_path)
	if (some_path == @pd || some_path == "/var/log")
		true
	else
		false
	end
end

def slp
	if ARGV.count == 0
		@pa.each {|pkg|
			puts pkg
		}
	else
		ARGV.each {|arg|
			puts @pa.grep(/#{arg}/)
		}
	end
end

def slt
	if ARGV.count == 0
		@pa.each {|pkg|
			file_time = File.mtime(sl_path(pkg))
			puts "#{pkg}:\s#{file_time}"
		}
	else
		ARGV.each {|arg|
			@pa.grep(/#{arg}/).each {|pkg|
				next if is_sl_pd?(sl_path(pkg))
				file_time = File.mtime(sl_path(pkg))
				puts "#{pkg}:\s#{file_time}"
			}
		}
	end
end


def slf
	if ARGV.count == 0
		puts "#{@me}: what file do you want me to search for?"
	else
		ARGV.each {|arg|
			r = Regexp::new(/#{arg}/)
			@pa.each {|pkg|
				p = sl_path(pkg)
				next if is_sl_pd?(p)
				f = File.open(p)
				f.each {|line|
					# FIXME needs an UTF-8 solution
					o = line.gsub! r, "#{@st}\\&#{@en}"
					puts pkg + ":\s" + o if ! o.nil?
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
			@pa.grep(/#{arg}/).each {|pkg|
				p = sl_path(pkg)
				next if is_sl_pd?(p)
				system("tail +$(expr $(grep -n ^FILE #{p} | cut -d : -f 1 ) + 2) #{p} ")
			}
		}
	end
end

# XXX stub for slack-utils orpaned .new files (to be written in ruby)
def slo
end

