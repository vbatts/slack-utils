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
require 'slackware/paths'

MyTime = RUBY_VERSION < '1.9'? DateTime : Time


module Slackware
  class Package
    RE_FILE_LIST = /^FILE LIST:/
    RE_COMPRESSED_PACKAGE_SIZE = /^COMPRESSED PACKAGE SIZE:\s+(.*)$/
    RE_UNCOMPRESSED_PACKAGE_SIZE = /^UNCOMPRESSED PACKAGE SIZE:\s+(.*)$/
    RE_PACKAGE_LOCATION = /^PACKAGE LOCATION:\s+(.*)$/
    RE_PACKAGE_DESCRIPTION = /^PACKAGE DESCRIPTION:\s+(.*)$/

    FMT_UPGRADE_TIME = "%F %H:%M:%S"

    attr_accessor :path, :file, :name, :version, :arch, :build, :tag, :tag_sep, :upgrade_time
    #attr_accessor :time, :owned_files
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
        self.upgrade_time = MyTime.strptime($2 + ' ' + $3, fmt=FMT_UPGRADE_TIME)
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
      return @package_description unless @package_description.nil?

      f = File.open(path() + '/' + self.fullname)
      loop do
        if (f.readline =~ RE_PACKAGE_DESCRIPTION)
          @package_description = f.take_while {|l|
            not(l =~ RE_FILE_LIST)
          }.map {|l|
            l.sub(/^#{self.name}:\s?/, '').chomp
          }
          return @package_description
        end
      end
    end

    # Setter for the PACKAGE DESCRIPTION, in the event you are parsing a repo file
    def package_description=(desc)
      @package_description = desc
    end

    # Accessor for the PACKAGE LOCATION from the package file
    def package_location
      return @package_location unless @package_location.nil?

      f = File.open(self.path + '/' + self.fullname)
      loop do
        if (f.readline =~ RE_PACKAGE_LOCATION)
          return @package_location = $1
        end
      end
    end

    # Setter for the PACKAGE LOCATION, in the event you are parsing a repo file
    def package_location=(path)
      @package_location = path
    end

    # Accessor for the UNCOMPRESSED PACKAGE SIZE from the package file
    def uncompressed_size
      return @uncompressed_size unless @uncompressed_size.nil?

      f = File.open(self.path + '/' + self.fullname)
      loop do
        if (f.readline =~ RE_UNCOMPRESSED_PACKAGE_SIZE)
          return @uncompressed_size = $1
        end
      end
    end

    # Setter for the UNCOMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
    def uncompressed_size=(size)
      @uncompressed_size = size
    end

    # Accessor for the COMPRESSED PACKAGE SIZE from the package file
    def compressed_size
      return @compressed_size unless @compressed_size.nil?

      f = File.open(self.path + '/' + self.fullname)
      loop do
        if (f.readline =~ RE_COMPRESSED_PACKAGE_SIZE)
          return @compressed_size = $1
        end
      end
    end

    # Setter for the COMPRESSED PACKAGE SIZE, in the event you are parsing a repo file
    def compressed_size=(size)
      @compressed_size = size
    end

    # Set the file list in the package object in memory
    def owned_files
      @owned_files ||= _owned_files()
    end

    # Accessor for the FILE LIST from the package file
    # unless the :owned_files symbol is populated
    def _owned_files
      files = []
      File.open(self.path + '/' + self.fullname) do |f|
        loop do
          break if f.eof?
          line = f.readline()
        begin
            if line.force_encoding("US-ASCII") =~ RE_FILE_LIST
              f.seek(2, IO::SEEK_CUR)
              break
            end
          rescue ArgumentError
            # ArgumentError: invalid byte sequence in US-ASCII
            # so dumb, i wish i could determine a better solution for this
            true
          end
        end
        begin
          files = f.readlines().map {|line| line.rstrip.force_encoding("US-ASCII") }
        rescue ArgumentError
          Log.instance.debug("Slackware::Package") {
            "encoding in : " + self.path + '/' + self.fullname
          }
        end
      end
      return files
    end

    # populates and returns self.time
    def time
      if (@time.nil? && self.path)
        if (File.exist?(self.path + "/" + self.fullname))
          @time = File.mtime(self.path + "/" + self.fullname)
        end
      elsif (not(self.path) && (@time.nil?))
        if (File.exist?(Paths::installed_packages() + "/" + self.fullname))
          @time = File.mtime(Paths::installed_packages() + "/" + self.fullname)
        end
      end
      return @time
    end

    # Fill in the path information
    def path
      @path ||= Paths::installed_packages()
    end

    def to_h
      {
        "name" => @name,
        "version" => @version,
        "arch" => @arch,
        "build" => @build,
        "tag" => @tag,
        "tag_sep" => @tag_sep,
        "upgrade_time" => @upgrade_time,
        "compressed_size" => compressed_size(),
        "uncompressed_size" => uncompressed_size(),
        "path" => path(),
        "time" => time(),
        "owned_files" => owned_files(),
      }
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

# vim:sw=2:sts=2:et:
