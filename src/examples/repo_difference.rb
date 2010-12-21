#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

pkgs = Slackware::System.installed_packages.map {|p| p.name }
sr = Slackware::Repo.new
sr.version = "current"
c = sr.get_changelog

printf("difference between current installation and %s...\n", sr.version)
printf("%d should be removed\n", (pkgs & c[:removed].map {|p| p.name }).count)
#p pkgs & c[:removed].map {|p| p.name }
ca = c[:added].map {|p| p.name }
printf("%d should be added\n", (ca.count - (pkgs & ca).count))
