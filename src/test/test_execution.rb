#!/usr/bin/env ruby
# http://en.wikibooks.org/wiki/Ruby_Programming/Unit_testing

$bin_path = File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../bin/")
$lib_path = File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/")
$:.insert(0, $lib_path)

require 'test/unit'

class TestExecution < Test::Unit::TestCase
  def setup
    @prev_root_env = ENV["ROOT"]
    @prev_rubylib_env = ENV["RUBYLIB"]
    ENV["ROOT"] = File.join(File.dirname(File.expand_path(__FILE__)), 'samples')
    ENV["RUBYLIB"] = $lib_path
  end
  def teardown
    ENV["RUBYLIB"] = @prev_rubylib_env
    ENV["ROOT"] = @prev_root_env
  end

  def test_slp
     res = nil
     IO.popen("ruby %s/slp bash" % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal(2, res.split("\n").length, "the command did not return the correct number of results")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_slf
     res = nil
     IO.popen("ruby %s/slf bin/bash" % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal("bin/bash4.new", res.split(": ").last.chomp, "the expected file was not found")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_slt
     res = nil
     IO.popen("ruby %s/slt -e -p ^bash$ " % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal("1328035381", res.chomp.split(": ").last, "the command did not return the expected time of the package")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_slu
     res = nil
     IO.popen("ruby %s/slu -p ^bash$ " % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal(2, res.split("\n").length, "the command did not return the correct number of results")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_sli
     res = nil
     IO.popen("ruby %s/sli -p ^bash$ " % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal(13, res.split("\n").length, "the command did not return the correct number of results")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_sll
     res = nil
     IO.popen("ruby %s/sll bash" % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal(316, res.split("\n").length, "the command did not return the correct number of results")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end

  def test_slo
     res = nil
     IO.popen("ruby %s/slo " % $bin_path) {|io| res = io.read }
     pid = $?
     assert_equal("", res.chomp, "the expected file was not found")
     assert_equal(true, pid.success?, "the process did not return successfully")
  end
end

# vim : set sw=2 sts=2 et :
