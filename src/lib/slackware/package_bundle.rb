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

module Slackware
  class PackageBundle < Package
                attr_accessor :archive

    def initialize(name = nil)
      super
    end

                def parse(name)
                        super(name)
                        if self.build =~ /^(\d+.*)\.(t[gx]z)$/
                                self.build = $1
                                self.archive = $2
                        elsif self.tag =~ /^(.*)\.(t[gx]z)$/
                                self.tag = $1
                                self.archive = $2
                        end
                end

    def get_file_list
                        pkg = "%s/%s.%s" % [self.path, self.fullname, self.archive]
                        return nil unless File.exist?(pkg)

      e_flag = ""
      if pkg =~ /txz$/
        e_flag = "J"
      elsif pkg =~ /tgz$/
        e_flag = "z"
      elsif pkg =~ /tbz$/
        e_flag = "j"
      end
      IO.popen("tar #{e_flag}wtf #{pkg}") {|f|
        f.readlines.map {|l| l.chomp }
      } 
    end

    def read_file(file)
                        pkg = "%s/%s.%s" % [self.path, self.fullname, self.archive]
                        return nil unless File.exist?(pkg)

      e_flag = ""
      if pkg =~ /txz$/
        e_flag = "J"
      elsif pkg =~ /tgz$/
        e_flag = "z"
      elsif pkg =~ /tbz$/
        e_flag = "j"
      end
      IO.popen("tar #{e_flag}xOf #{pkg} #{file}") {|f| f.read }
    end

    def inspect
      "#<%s:0x%x name=%s version=%s arch=%s build=%s tag=%s archive=%s>" % [
        self.class.name,
        self.object_id,
        self.name.inspect,
        self.version.inspect,
        self.arch.inspect,
        self.build,
        self.tag.inspect,
                                self.archive.inspect
      ]
    end
  end
end
# vim : set sw=2 sts=2 noet :
