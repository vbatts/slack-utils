#!/usr/bin/env ruby

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

def log(msg)
    Slackware::Log.instance.info(File.basename(__FILE__)) { msg }
end

class TestSystem < Test::Unit::TestCase
  def setup
    @root_prev = ENV["ROOT"]
    ENV["ROOT"] = File.join(File.dirname(__FILE__), 'samples')
    log( "ROOT: #{ENV["ROOT"]} ")
  end
  def teardown
    ENV["ROOT"] = @root_prev
  end

  def test_installed_packages
    a = Slackware::System.installed_packages()
    log(a)
    assert_equal(2, a.length, "There should only two packages showing as installed")
  end
  def test_removed_packages
    a = Slackware::System.removed_packages()
    log(a)
    assert_equal(2, a.length, "There should only two packages showing as removed")
  end
  def test_installed_scripts
    a = Slackware::System.installed_scripts()
    log(a)
    assert_equal(2, a.length, "There should only two scripts showing as installed")
  end
  def test_removed_scripts
    a = Slackware::System.removed_scripts()
    log(a)
    assert_equal(2, a.length, "There should only two scripts showing as removed")
  end

  def test_tags_used_count
    a = Slackware::System.tags_used()
    log(a)
    assert_equal(1, a.length, "There should only one tags showing")
  end
  def test_tags_used_strings
    a = Slackware::System.tags_used()
    log(a)
    assert_equal("", a.first[:tag], "Only testing stock tags so far")
  end
  def test_tags_used_count_count
    a = Slackware::System.tags_used()
    log(a)
    assert_equal(2, a.first[:count], "Only testing two stock tags so far")
  end

  def test_with_tag
    a = Slackware::System.with_tag("")
    log(a)
    assert_equal(2, a.count, "Only testing two stock tags so far")
  end

  def test_arch_used
    a = Slackware::System.arch_used()
    log(a)
    assert_equal(1, a.count, "Only testing x86_64 so far")
    assert_equal("x86_64", a.first, "Only testing x86_64 so far")
  end
end

# vim : set sw=2 sts=2 noet :
