#!/usr/bin/env ruby
# http://en.wikibooks.org/wiki/Ruby_Programming/Unit_testing

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

class TestRepoDefaults < Test::Unit::TestCase
  def setup
    # #<Slackware::Repo:0x00000000e76cb8 @packages=nil, @proto="ftp://", @mirror="ftp.osuosl.org", @path="/pub/slackware/", @version="13.1", @arch="64">
    @repo = Slackware::Repo.new
  end

  def teardown
    # nothing really
    @repo = nil
  end

  def test_packages
    assert_equal(nil, @repo.packages)
  end
  
  def test_proto
    t_proto = "ftp://"
    @repo.proto = t_proto
    assert_equal(t_proto, @repo.proto)
  end
  
  def test_mirror
    t_mirror = "ftp.osuosl.org"
    @repo.mirror = t_mirror
    assert_equal(t_mirror, @repo.mirror)
  end

  def test_path
    t_path = "/pub/slackware/"
    @repo.path = t_path
    assert_equal(t_path, @repo.path)
  end

  def test_version
    t_version = "13.1"
    @repo.version = t_version
    assert_equal(t_version, @repo.version)
  end

  def test_arch
    t_arch = "64"
    @repo.arch = t_arch
    assert_equal(t_arch, @repo.arch)
  end
end

class TestRepoFunctions < Test::Unit::TestCase
  def setup
    # #<Slackware::Repo:0x00000000e76cb8 @packages=nil, @proto="ftp://", @mirror="ftp.osuosl.org", @path="/pub/slackware/", @version="13.1", @arch="64">
    @repo = Slackware::Repo.new
  end

  def teardown
    # nothing really
    @repo = nil
  end

  def test_get_packages
    #pkgs = @repo.get_packages # FIXME time out ...
    #assert_equal(true, pkgs.count > 100)
    true
  end

  def test_set_packages
    #@repo.set_packages # FIXME time out ...
    #assert_equal(true, @repo.packages.count > 100)
    true
  end
end
# vim : set sw=2 sts=2 et :
