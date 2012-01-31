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

module Slackware
  module Paths
    INSTALLED_PACKAGES = "/var/log/packages"
    REMOVED_PACKAGES = "/var/log/removed_packages"
    INSTALLED_SCRIPTS = "/var/log/scripts"
    REMOVED_SCRIPTS = "/var/log/removed_scripts"
 
    # A helper to return the ROOT directory of the system in question.
    # Like pkgtools, if the environment has "ROOT" set, use it, otherwise "/"
    def self::root_dir()
      return ENV["ROOT"] ? ENV["ROOT"] : "/"
    end
    
    def self::installed_packages(*args)
      return File.join(root_dir, INSTALLED_PACKAGES, args)
    end

    def self::removed_packages(*args)
      return File.join(root_dir, REMOVED_PACKAGES, args)
    end

    def self::installed_scripts(*args)
      return File.join(root_dir, INSTALLED_SCRIPTS, args)
    end

    def self::removed_scripts(*args)
      return File.join(root_dir, REMOVED_SCRIPTS, args)
    end
  end # module Paths
end # module Slackware

# vim:sw=2:sts=2:noet:
