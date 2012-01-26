#!/usr/bin/ruby

$: <<  File.absolute_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'slackware'

sr = Slackware::Repo.new
sr.version = "current"
sr.set_changelog

pkgs = Slackware::System.installed_packages

@@upgrades = []
sr.changelog[:rebuilt].concat(sr.changelog[:upgraded]).each {|pkg|
  i_pkg = pkgs.map {|item| item if item.name == pkg.name }.compact.first
  if i_pkg.nil?
    next
  end
  if pkg.version < i_pkg.version 
    next
  end
  if pkg.fullname > i_pkg.fullname 
    @@upgrades << pkg
  end
}

p @@upgrades
# vim : set sw=2 sts=2 noet :
