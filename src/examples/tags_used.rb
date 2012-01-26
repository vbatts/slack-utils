#!/usr/bin/ruby -w

$: <<  File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

p Slackware::System.tags_used
# vim : set sw=2 sts=2 noet :
