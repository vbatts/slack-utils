#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

puts "tags used are: " + Slackware::System.tags_used.to_s

pkg = "kernel-modules"
if (Slackware::System.is_upgraded?(pkg))
	puts pkg + " has been upgraded before"
	Slackware::System.upgrades(pkg).each {|up| printf("%s upgraded from version %s\n", up.upgrade_time, up.version) }
else
	puts pkg + " apparently has not ever been upgraded before"
end

