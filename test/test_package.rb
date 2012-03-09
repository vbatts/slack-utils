#!/usr/bin/env ruby

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

def log(msg)
    Slackware::Log.instance.info(File.basename(__FILE__)) { msg }
end

class TestPackage < Test::Unit::TestCase
  def setup
    @root_prev = ENV["ROOT"]
    ENV["ROOT"] = File.expand_path(File.join(File.dirname(__FILE__), 'samples'))
    log( "ROOT: #{ENV["ROOT"]} ")
  end
  def teardown
    ENV["ROOT"] = @root_prev
  end

  def test_upgrade_time
	  upgraded = []
	  removed = []
	  Slackware::System.removed_packages().each do |pkg|
		  if pkg.upgrade_time
			  upgraded << pkg
		  else
			  removed << pkg
		  end
	  end

	  assert_equal(1, upgraded.length, "only one upgraded package to test")
	  assert_equal(1, removed.length, "only one removed package to test")

	  res = upgraded.map {|i| i.upgrade_time.class }.uniq
	  assert_equal(1, res.length, "should only be 1")
	  assert_equal(Time, res.first, "should only be a Time")

	  res = removed.map {|i| i.upgrade_time.class }.uniq
	  assert_equal(1, res.length, "should only be 1")
	  assert_equal(NilClass, res.first, "should only be a nil")
  end

end

# vim : set sw=2 sts=2 et :
