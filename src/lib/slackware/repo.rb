# encoding: UTF-8

# Copyright 2010,2011  Vincent Batts, Vienna, VA
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

require 'slackware/package'
require 'slackware/log'
require 'slackware/changelog'
require 'slackware/system'

require 'net/http'
require 'net/ftp'
require 'rbconfig'

module Slackware

  # Stub
  class Repo
    RE_PACKAGE_NAME    = /^PACKAGE NAME:\s+(.*)\.t[gbx]z\s*/
    RE_PACKAGE_LOCATION  = /^PACKAGE LOCATION:\s+(.*)$/
    RE_COMPRESSED_SIZE  = /^PACKAGE SIZE \(compressed\):\s+(.*)$/
    RE_UNCOMPRESSED_SIZE  = /^PACKAGE SIZE \(uncompressed\):\s+(.*)$/

    attr_accessor :proto, :mirror, :path, :version, :arch, :changelog, :packages, :uri

    def initialize(repo = nil)
      @packages = nil
      if (repo.nil?)
        self.proto  = "ftp://"
        self.mirror  = "ftp.osuosl.org"
        self.path  = "/pub/slackware/"
        self.version  = begin 
                v = Slackware::System.version
                if v =~ /(\d+)\.(\d+)\.\d+/
                  v = $1 + "." + $2
                end
                v
              end
        self.arch = RbConfig::CONFIG["arch"] =~ /x86_64/ ? "64" : ""
      else
        ## TODO do some hot parsing of 'repo'
        self.uri = URI.parse(repo)
      end
    end

    def url
      "%s%s%sslackware%s-%s/" % [self.proto,
                                 self.mirror,
                                 self.path,
                                 self.arch,
                                 self.version]
    end

    def url=(thisurl)
      self.uri = URI.parse(thisurl)
    end

    def fetch(file = nil)
      #if file.nil?
        #url = URI.parse(self.proto + self.mirror + self.path)
      #else
        #url = URI.parse(self.proto + self.mirror + self.path + file)
      #end
      if self.proto =~ /ftp/
        ftp = Net::FTP.open(self.mirror)
        ftp.login
        ftp.chdir(self.path + "slackware" + self.arch + "-" + self.version)
        if (file.nil?)
          data = ftp.list('*')
        else
          data = ftp.get(file, nil)
        end
        ftp.close
        return data
      elsif self.proto =~ /http/
        # XXX this is not working yet
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
        return res
      elsif self.proto =~ /file/
        if (file.nil?)
          return Dir.glob(self.path + "slackware" + self.arch + "-" + self.version + "/*")
        else
          return File.read(self.path + "slackware" + self.arch + "-" + self.version + "/" + file)
        end
      else
        return nil
      end
    end

    # Pkg count that _should_ be removed
    # pkgs = Slackware::System.installed_packages
    # sr = Slackware::Repo.new
    # sr.version = "current"
    # c = get_changelog
    #(pkgs.map {|p| p.fullname } & c[:removed].map {|p| p.fullname }).count
    def get_changelog
      if (@changelog.nil?)
        changelog = {}
        changelog_data = fetch("ChangeLog.txt")
        return changelog
      else
        return @changelog
      end
    end

    def set_changelog
      @changelog = get_changelog
      return nil
    end

    def get_packages
      if (@packages.nil?)
        pkgs = []
        fetch("PACKAGES.TXT").split(/\n\n/).each {|p_block|
          p_block = p_block.split(/\n/).reject {|cell| cell if cell == "" }
          if (p_block.shift =~ RE_PACKAGE_NAME)
            pkg = Slackware::Package.parse($1)

            p_block.shift =~ RE_PACKAGE_LOCATION
            pkg.package_location = $1

            p_block.shift =~ RE_COMPRESSED_SIZE
            pkg.compressed_size = $1

            p_block.shift =~ RE_UNCOMPRESSED_SIZE
            pkg.uncompressed_size = $1

            # This is the empty PACKAGE DESCRIPTON: tag
            p_block.shift

            pkg.package_description = p_block.map {|cell|
              cell.sub(/^#{pkg.name}:\s*/, '')
            }

            pkgs << pkg
          end
        }
        return pkgs
      else
        return @packages
      end
    end

    def set_packages
      @packages = get_packages
      return @packages.count
    end

  end


end

# vim : set sw=2 sts=2 et :
