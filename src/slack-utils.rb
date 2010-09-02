#!/usr/bin/env ruby 
# started - Fri Oct	9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010
# Copyright 2009, 2010 Vincent Batts, http://hashbangbash.com/

ENV['LC_ALL'] = nil if not ENV['LC_ALL'].nil?
ENV['LC_LANG'] = nil if not ENV['LC_LANG'].nil?
ENV['LC_COLLATE'] = nil if not ENV['LC_COLLATE'].nil?

# Variables
@pd = '/var/log/packages'
@pa = Dir.entries(@pd)
@me = File.basename($0)
@st = "\033[31;1m"
@en = "\033[0m"

# Functions
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
			p = File.absolute_path File.join(@pd, '/', pkg)
			f = File.open(p)
			ft = f.mtime
			puts "#{pkg}:\s#{ft}"
		}
	else
		ARGV.each {|arg|
			@pa.grep(/#{arg}/).each {|pkg|
				p = File.absolute_path File.join(@pd, '/', pkg)
				f = File.open(p)
				ft = f.mtime
				puts "#{pkg}:\s#{ft}"
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
				p = File.absolute_path File.join(@pd, '/', pkg)
				if p == @pd || p == "/var/log"
						next
				end
				f = File.open(p)
				f.each {|line|
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
				p = File.absolute_path File.join(@pd, '/', pkg)
				if p == @pd || p == "/var/log"
						next
				end
				system("tail +$(expr $(grep -n ^FILE #{p} | cut -d : -f 1 ) + 2) #{p} ")
			}
		}
	end
end

# XXX stub for slack-utils orpaned .new files (to be written in ruby)
def slo
end

