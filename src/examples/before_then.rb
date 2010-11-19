#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'slackware'

t = Time.now - 10000877
s = Slackware.installed_before(t)

puts "#{s.count} packages installed before #{t}"
