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

require 'time'
require 'slackware/log'

module Slackware
  class Package
    attr_accessor :time, :path, :file, :name, :version, :arch, :build, :tag, :tag_sep, :upgrade_time, :owned_files
    def initialize(name = nil)
      self.name = name
    end

    # pkg.parse instance method for parsing the package information
    def parse(name)
      if name.include?("/")
        self.path = File.dirname(name)
        name = File.basename(name)
      end
      if (name =~ RE_REMOVED_NAMES)
        name = $1
        self.upgrade_time = Time.strptime($2 + ' ' + $3, fmt='%F %H:%M:%S')
      end
      arr = name.split('-')
      build = arr.pop
      if (build.include?("_"))
        self.tag_sep = "_"
        self.build = build.split(self.tag_sep)[0]
        self.tag = build.split(self.tag_sep)[1..-1].join(self.tag_sep)
      elsif (build =~ RE_BUILD_TAG)
        self.build = $1
        self.tag = $2
      else
        self.build = build
        self.tag = ""
      end
      self.arch = arr.pop
      self.version = arr.pop
      self.name = arr.join('-')
    end

    # Package.parse class method
    def self::parse(name)
      p = self.new()
      p.parse(name)
      return p
    end
    
    # Reassemble the package name as it would be in file form
    def fullname
      if (self.upgrade_time)
        time = self.upgrade_time.strftime("%F,%H:%M:%S")
        return [self.name, self.version, self.arch, [self.build, self.tag].join(self.tag_sep), "upgraded", time].join("-")
      else
        return [self.name, self.version, self.arch, [self.build, self.tag].join(self.tag_sep)].join("-")
      end
    end

    # Accessor for the PACKAGE DESCRIPTION from the package file
    def package_description
      if not(@package_description.nil?)
        return @package_description
      end

      f = File.open(self.path + '/' + self.fullname)
      while true
        if (f.readline =~ /^PACKAGE DESCRIPTION:\s+(.*)$/)
          desc = f.take_while {|l|
                                                not(l =~ /FILE LIST:/)
                                        }.map {|l|
                                                l.sub(/^#{self.name}:\s?/, '').chomp
                                        }
          return desc
        end
      end
    end

    # Setter for the PACKAGE DESCRIPTION, in the event you are parsing a repo file
    def package_description=(desc)
      @package_description = desc
    end

    # Accessor for the PACKAGE LOCATION from the package file
    def package_location
      if not(@package_location.nil?)
        return @package_location
      end

      f = File.open(self.path + '/' + self.fullname)
      while true
        if (f.readline =~ /^PACKAGE LOCATION:\s+(.*)$/)
          return $1
        end
      end
    end

    # Setter for the PACKAGE LOCATION, in the event you are parsing a repo file
    def package_location=(path)
      @package_location = path
    end

    # Accessor for the UNCOMPRESSED PACKAGE SIZE from the package file
    def uncompressed_size
      if not(@uncompressed_size.nil?)
        return @uncompressed_size
      end

      f = File.open(self.path + '/' + self.fullname)
      while true
        if (f.readline =~ /^UNCOMPRESSED PACKAGE SIZE:\s+(.*)$/)
          return $1
        end
      end
    end

    # Setter for the UNCOMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
    def uncompressed_size=(size)
      @uncompressed_size = size
    end

    # Accessor for the COMPRESSED PACKAGE SIZE from the package file
    def compressed_size
      if not(@compressed_size.nil?)
        return @compressed_size
      end

      f = File.open(self.path + '/' + self.fullname)
      while true
        if (f.readline =~ /^COMPRESSED PACKAGE SIZE:\s+(.*)$/)
          return $1
        end
      end
    end

    # Setter for the COMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
    def compressed_size=(size)
      @compressed_size = size
    end

    # Accessor for the FILE LIST from the package file
    # unless the :owned_files symbol is populated
    def get_owned_files
      unless self.owned_files.nil?
        return self.owned_files
      else
        files = nil
        File.open(self.path + '/' + self.fullname) do |f|
          while true
            break if f.eof?
            line = f.readline()
            if line =~ /^FILE LIST:/ # FIXME ArgumentError: invalid byte sequence in US-ASCII
              f.seek(2, IO::SEEK_CUR)
              break
            end
          end
          files = f.read().split()
        end
        return files
      end
    end

    # Set the file list in the package object in memory
    def set_owned_files
      if self.owned_files.nil?
        self.owned_files = get_owned_files()
        return true
      else
        return false
      end
    end

    # populates and returns self.time
    def get_time
      if (self.time.nil? && self.path)
        if (File.exist?(self.path + "/" + self.fullname))
          self.time = File.mtime(self.path + "/" + self.fullname)
        end
      elsif (not(self.path) && (self.time.nil?))
        if (File.exist?(DIR_INSTALLED_PACKAGES + "/" + self.fullname))
          self.time = File.mtime(DIR_INSTALLED_PACKAGES + "/" + self.fullname)
        end
      end
      return self.time
    end

    # Fill in the path information
    def get_path
      if (self.path.nil? && File.exist?(DIR_INSTALLED_PACKAGES + "/" + self.name))
        self.path = DIR_INSTALLED_PACKAGE
        return DIR_INSTALLED_PACKAGE
      end
    end

    def inspect
      "#<%s:0x%x name=\"%s\" version=\"%s\" arch=\"%s\" build=%s tag=\"%s\">" % [
        self.class.name,
        self.object_id,
        self.name,
        self.version,
        self.arch,
        self.build,
        self.tag
      ]
    end

  end

  class Script < Package
    attr_accessor :script

    def initialize(name = nil)
      self.script = true
      super
    end

    def parse(name)
      super
      self.script = true
    end

  end
end
# vim : set sw=2 sts=2 noet :
