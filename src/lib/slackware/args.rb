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

require 'optparse'

module Slackware
  # Args is the unified arguement parser for the slack-utils utilities.
  class Args
    def self.parse(args,flags = nil, banner = nil)
      flags = [] unless flags.is_a?(Array)
      options = {}

      opts = OptionParser.new do |opts|
        if banner
          opts.banner = banner
        end
        if flags.include?(:color)
          opts.on("-c", "--color", "Colorize output") do |o|
            options[:color] = o
          end
        end
        if flags.include?(:reverse)
          opts.on("-r", "--reverse", "Reverse the output") do |o|
            options[:reverse] = o
          end
        end
        if flags.include?(:epoch)
          opts.on("-e", "--epoch", "Print the time stamp in seconds since 1970-01-01 00:00:00 UTC ") do |o|
            options[:epoch] = o
          end
        end
        if flags.include?(:pkg_name)
          opts.on("-p", "--pkg [NAME]", "Package PKGNAME (loose match)") do |o|
            options[:pkg] = o
          end
        end
        if flags.include?(:pkg_version)
          opts.on("-V", "--Version [VERSION]", "Package VERSION (loose match)") do |o|
            options[:version] = o
          end
        end
        if flags.include?(:pkg_arch)
          opts.on("-a", "--arch [ARCH]", "Package ARCH (exact match)") do |o|
            options[:arch] = o
          end
        end
        if flags.include?(:pkg_build)
          opts.on("-b", "--build [BUILD]", "Package BUILD (exact match)") do |o|
            options[:build] = o
          end
        end
        if flags.include?(:pkg_tag)
          opts.on("-t", "--tag [TAG]", "Package TAG (loose match)") do |o|
            options[:tag] = o
          end
        end
        if flags.include?(:case_insensitive)
          opts.on("-i", "When searching, do a case insensitive match") do |o|
            options[:case_insensitive] = o
          end
        end
        if flags.include?(:force_all)
          opts.on("-f", "--force", "force me to show all files") do |o|
            options[:force] = o
          end
        end
        if flags.include?(:debug)
          opts.on("-D", "--debug", "show debugging output") do |o|
            options[:debug] = o
          end
        end

        opts.on("-v", "--version", "Display version of this software") do |o|
          printf("slack-utils version: %s, Slackware version: %s\n",
                   Slackware::UTILS_VERSION,
                   Slackware::System.version
                )
          exit(0)
        end
      end

      begin
        opts.parse!
        return options
      rescue OptionParser::InvalidOption => ex
        $stderr.write("ERROR: #{e.message}, see --help\n")
        exit(1)
      end
    end
  end
end
# vim : set sw=2 sts=2 et :
