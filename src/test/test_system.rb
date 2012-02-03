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
    assert_equal(3, a.length, "There should only two packages showing as installed")
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

  def test_find_installed
    a = Slackware::System.find_installed('bash')
    log(a)
    assert_equal(2, a.length, "bash and bash-completion should match")
  end
  def test_find_removed
    a = Slackware::System.find_removed('bash')
    log(a)
    assert_equal(1, a.length, "There should only be one bash package removed")
  end
  def test_upgrades
    a = Slackware::System.upgrades('bash')
    log(a)
    assert_equal(1, a.length, "There should only be one bash package upgrades")

    a = Slackware::System.upgrades('fart')
    assert_equal(0, a.length, "There should not be any fart upgrades")
  end

  def test_is_upgraded
    a = Slackware::System.is_upgraded?('bash')
    assert_equal(true, a, "bash should have an upgrade present")

    a = Slackware::System.is_upgraded?('fart')
    assert_equal(false, a, "fart should not have an upgrade present")
  end

  def test_tags_used
    a = Slackware::System.tags_used()
    log(a)
    assert_equal(1, a.length, "There should only one tags showing")
    assert_equal("", a.first[:tag], "Only testing stock tags so far")
    assert_equal(3, a.first[:count], "Only testing two stock tags so far")
  end

  def test_with_tag
    a = Slackware::System.with_tag("")
    log(a)
    assert_equal(3, a.count, "Only testing two stock tags so far")
  end

  def test_arch_used
    a = Slackware::System.arch_used()
    log(a)
    assert_equal(2, a.count, "Only testing noarch and x86_64 so far")
    assert_equal(%w{ noarch x86_64 }.sort, a.sort, "Only testing noarch and x86_64 so far")
  end

  def test_owns_file
    a = Slackware::System.owns_file('/bin/bash')
    log( 'owns_file' )
    log( a )
    assert_equal(1, a.count, "Only the bash package should own this pattern")
    pkg = a.first.first
    assert_equal('bash', pkg.name, "Only the bash package should own this pattern")
  end

  def test_removed_after
    t = Time.at(1)
    a = Slackware::System.removed_after(t)
    assert_equal(1, a.length, "check the times on the packages")
  end

  def test_removed_before
    t = Time.now()
    a = Slackware::System.removed_before(t)
    assert_equal(1, a.length, "check the times on the packages")
  end

  def test_installed_after
    t = Time.at(1)
    a = Slackware::System.installed_after(t)
    assert_equal(5, a.length, "check the times on the packages")
  end

  def test_installed_before
    t = Time.now
    a = Slackware::System.installed_before(t)
    assert_equal(5, a.length, "check the times on the packages")
  end

  def test_version
    a = Slackware::System.version()
    assert_not_nil(a, "The version of Slackware should be set")
  end
end

# vim : set sw=2 sts=2 et :
