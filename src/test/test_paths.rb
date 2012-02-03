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
    ENV["ROOT"] = nil
    @alt_root = File.join(File.dirname(__FILE__), 'samples')
  end
  def teardown
    ENV["ROOT"] = @root_prev
  end

  def _no_root(&block)
    ENV["ROOT"] = nil
    yield
  end

  def _alt_root(&block)
    ENV["ROOT"] = @alt_root
    yield
    ENV["ROOT"] = @root_prev
  end

  def test_root_dir
    _no_root {
      a = Slackware::Paths.root_dir()
      assert_equal('/', a, 'root path is not properly deduced')
    }
  end

  def test_installed_packages
    _no_root {
      assert_equal("/var/log/packages/",Slackware::Paths.installed_packages())
    }
  end
  def test_removed_packages
    _no_root {
      assert_equal("/var/log/removed_packages/",Slackware::Paths.removed_packages())
    }
  end
  def test_installed_scripts
    _no_root {
      assert_equal("/var/log/scripts/",Slackware::Paths.installed_scripts())
    }
  end
  def test_removed_scripts
    _no_root {
      assert_equal("/var/log/removed_scripts/",Slackware::Paths.removed_scripts())
    }
  end

  def test_root_dir_alt
    _alt_root {
      a = Slackware::Paths.root_dir()
      assert_equal(ENV["ROOT"], a, 'root path is not properly deduced')
    }
  end

  def test_installed_packages_alt
    _alt_root {
      assert_equal(File.join(ENV["ROOT"],"var/log/packages",''),Slackware::Paths.installed_packages())
    }
  end
  def test_removed_packages_alt
    _alt_root {
      assert_equal(File.join(ENV["ROOT"],"var/log/removed_packages",''),Slackware::Paths.removed_packages())
    }
  end
  def test_installed_scripts_alt
    _alt_root {
      assert_equal(File.join(ENV["ROOT"],"var/log/scripts",''),Slackware::Paths.installed_scripts())
    }
  end
  def test_removed_scripts_alt
    _alt_root {
      assert_equal(File.join(ENV["ROOT"],"var/log/removed_scripts",''),Slackware::Paths.removed_scripts())
    }
  end
end

# vim : set sw=2 sts=2 et :
