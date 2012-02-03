#!/usr/bin/env ruby
# http://en.wikibooks.org/wiki/Ruby_Programming/Unit_testing

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

class TestBasics < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_utils_version
    assert_not_nil(Slackware::UTILS_VERSION)
  end
  def test_slackware_version
    assert_not_nil(Slackware::SLACKWARE_VERSION)
  end
  def test_slackware_system_version
    assert_not_nil(Slackware::System.version)
  end
end

# vim : set sw=2 sts=2 et :
