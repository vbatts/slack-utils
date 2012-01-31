#!/usr/bin/env ruby

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

def log(msg)
    Slackware::Log.instance.info(File.basename(__FILE__)) { msg }
end

class TestPaths < Test::Unit::TestCase
  def setup
    @root_prev = ENV["ROOT"]
    ENV["ROOT"] = File.join(File.dirname(__FILE__), 'samples')
    log( "ROOT: #{ENV["ROOT"]} ")
  end
  def teardown
    ENV["ROOT"] = @root_prev
  end

  def test_root_dir
    a = Slackware::Paths.root_dir()
    assert_equal(ENV["ROOT"], a, 'root path is not properly deduced')
  end

  def test_installed_packages
    assert_equal(1,1)
  end
end

# vim : set sw=2 sts=2 et :
