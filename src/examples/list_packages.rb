#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

puts "tags used are: " + Slackware.tags_used.to_s

pkg = "kernel-modules"
if (Slackware.is_upgraded?(pkg))
	puts pkg + " has been upgraded before!"
	Slackware.upgrades(pkg).each {|up| puts up.inspect }
else
	puts pkg + " apparently has not ever been upgraded before"
end

