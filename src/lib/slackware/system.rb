# encoding: UTF-8

# Copyright 2010,2011,2012  Vincent Batts, Vienna, VA
# All rights reserved.
#
# Redistribution and use of this source, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this source must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'slackware/version'
require 'slackware/package'
require 'slackware/log'

module Slackware
  DIR_INSTALLED_PACKAGES = "/var/log/packages"
  DIR_REMOVED_PACKAGES = "/var/log/removed_packages"
  DIR_INSTALLED_SCRIPTS = "/var/log/scripts"
  DIR_REMOVED_SCRIPTS = "/var/log/removed_scripts"
  RE_REMOVED_NAMES = /^(.*)-upgraded-(\d{4}-\d{2}-\d{2}),(\d{2}:\d{2}:\d{2})$/
  RE_BUILD_TAG = /^([[:digit:]]+)([[:alpha:]]+)$/

  class System
    # A debug log helper
    def self::debug(msg)
      Slackware::Log.instance.debug(self.name) { msg }
    end

    # A helper to return the ROOT directory of the system in question.
    # Like pkgtools, if the environment has "ROOT" set, use it, otherwise "/"
    def self::root_dir()
      return ENV["ROOT"] ? ENV["ROOT"] : "/"
    end
    
    def self::dir_installed_packages(*args)
      return File.join(root_dir, DIR_INSTALLED_PACKAGES, args)
    end

    def self::dir_removed_packages(*args)
      return File.join(root_dir, DIR_REMOVED_PACKAGES, args)
    end

    def self::dir_installed_scripts(*args)
      return File.join(root_dir, DIR_INSTALLED_SCRIPTS, args)
    end

    def self::dir_removed_scripts(*args)
      return File.join(root_dir, DIR_REMOVED_SCRIPTS, args)
    end

    def self::installed_packages
      path = dir_installed_packages("*")
      debug('dir_installed_packages: %s' % path)
      return Dir.glob(path).sort.map {|p| Package.parse(p) }
    end

    def self::removed_packages
      path = dir_removed_packages("*")
      debug('dir_removed_packages: %s' % path)
      return Dir.glob(path).sort.map {|p| Package.parse(p) }
    end

    def self::installed_scripts
      path = dir_installed_scripts("*")
      debug('dir_installed_scripts: %s' % path)
      return Dir.glob(path).sort.map {|s| Script.parse(s) }
    end

    def self::removed_scripts
      path = dir_removed_scripts("*")
      debug('dir_removed_scripts: %s' % path)
      return Dir.glob(path).sort.map {|s| Script.parse(s) }
    end

    def self::tags_used
      pkgs = installed_packages()
      set = []
      pkgs.map {|p| p.tag }.uniq.each {|tag|
        m_set = {}
        m_set[:tag] = tag
        m_set[:count] = pkgs.select {|p| p.tag == tag }.count
        set << m_set
      }
      return set
    end

    def self::with_tag(tag)
      return installed_packages().select {|pkg| pkg.tag == tag }
    end

    def self::arch_used
      return installed_packages().map {|p| p.arch }.uniq
    end

    def self::with_arch(arch)
      return installed_packages().select {|pkg| pkg.arch == arch }
    end

    def self::find_installed(name)
      d = Dir.new(dir_installed_packages())
      return d.select {|p| p.include?(name) }.map {|p| Package.parse(p) }
    end

    def self::find_removed(name)
      d = Dir.new(dir_removed_packages())
      return d.select {|p| p.include?(name) }.map {|p| Package.parse(p) }
    end

    # Returns a list of the upgrades for a particular package name
    # Example:
    #   Slackware::System.upgrades("xz")
    #   => [#<Slackware::Package:0x981e6c name="xz" version="5.0.0" arch="x86_64" build=1 tag="">,
    #   #<Slackware::Package:0x97e04c name="xz" version="4.999.9beta" arch="x86_64" build=1 tag="">]
    #   Slackware::System.upgrades("fart")
    #   => []
    def self::upgrades(pkg)
      find_removed(pkg).select {|p| (p.name == pkg) }
    end

    # Return an Array of packages, that were installed after provided +time+
    # ("installed" meaning the file's mtime)
    def self::installed_after(time)
      arr = []
      Dir.new(dir_installed_packages()).each {|p|
        if (File.mtime(dir_installed_packages(p)) >= time)
          pkg = Package.parse(p)
          pkg.get_time
          arr << pkg
        end
      }
      return arr
    end

    # Return an Array of packages, that were installed before provided +time+
    # ("installed" meaning the file's mtime)
    def self::installed_before(time)
      arr = []
      Dir.new(dir_installed_packages()).each {|p|
        if (File.mtime(dir_installed_packages(p)) <= time)
          pkg = Package.parse(p)
          pkg.get_time
          arr << pkg
        end
      }
      return arr
    end

    # Return an Array of packages, that were removed after provided +time+
    def self::removed_after(time)
      arr = []
      Dir.new(dir_removed_packages()).each {|p|
        if (dir_installed_packages(p) =~ RE_REMOVED_NAMES)
          if (Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S') >= time)
            arr << Package.parse(p)
          end
        end
      }
      return arr
    end

    # Return an Array of packages, that were removed before provided +time+
    def self::removed_before(time)
      arr = []
      Dir.new(dir_removed_packages()).each {|p|
        if (dir_installed_packages(p) =~ RE_REMOVED_NAMES)
          if (Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S') <= time)
            arr << Package.parse(p)
          end
        end
      }
      return arr
    end

    # Check whether a given Slackware::Package has been upgraded before
    def self::is_upgraded?(pkg)
      if (find_removed(pkg).map {|p| p.name if p.upgrade_time }.include?(pkg) )
        return true
      else
        return false
      end
    end

    # Search installation of Slackware::Package's for what owns the questioned file
    def self::owns_file(file)
      pkgs = installed_packages()
      debug('owns_file(): pkgs.count => %d' % pkgs.count)
      found_files = []
      file = file.sub(/^\//, "") # clean off the leading '/'
      re = Regexp::new(/#{file}/)
      debug('owns_file(): file Regexp => %' % re.inspect)
      pkgs.each {|pkg|
        pkg.get_owned_files().select {|f| f =~ re }.each do |f|
            found_files << [pkg, f]
        end
      }
      return found_files
    end

    # Return the version of Slackware Linux currently installed
    def self::version
      debug(SLACKWARE_VERSION)
      SLACKWARE_VERSION
    end
  end

end

# vim : set sw=2 sts=2 noet :
