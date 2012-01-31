#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

t = Time.now - 10000877
s = Slackware::System.installed_before(t)

puts "#{s.count} packages installed before #{t}"
# vim : set sw=2 sts=2 et :
