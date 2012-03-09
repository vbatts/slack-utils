#!/usr/bin/ruby -w

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware/repo'

sr = Slackware::Repo.new
sr.version = "current"

sr.set_packages

printf("%d packages in the slackware%s-%s repo\n", sr.packages.count, sr.arch, sr.version)

# vim : set sw=2 sts=2 et :
