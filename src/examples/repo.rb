#!/usr/bin/ruby -w

require 'rubygems'
require 'slackware-repo'

sr = Slackware::Repo.new
sr.version = "current"

sr.set_packages

printf("%d packages in the slackware%s-%s repo\n", sr.packages.count, sr.arch, sr.version)

