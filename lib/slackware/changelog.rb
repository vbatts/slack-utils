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
require 'date'
require 'time'
require 'stringio'

module Slackware
  # The class for parsing a Slackware standard ChangeLog.txt
  class ChangeLog

    # yanked from +Date+
    ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
    ABBR_MONTHNAMES = %w(Jan Feb Mar Apr May Jun
                         Jul Aug Sep Oct Nov Dec)

    # Compiling a fat regex to find the date entries
    re_daynames = Regexp.new(ABBR_DAYNAMES.join('|'))
    re_monthnames = Regexp.new(ABBR_MONTHNAMES.join('|'))
    RE_DATE = /^(#{re_daynames}\s+#{re_monthnames}\s+\d+\s+\d{2}:\d{2}:\d{2}\s\w+\s+\d+)$/
 
    # This break has been the same as long as I can find
    RE_CHANGELOG_BREAK = /^\+--------------------------\+$/

    # The regular entry, accounting for usb-and-pxe-installers directory,
    # and notes after the action
    re_package_entry0 = /^(([\w+-]+).*\/.*):\s+(\w+).*\.?$/
    # Some didn't have an action after the name
    re_package_entry1 = /^(([\w+-]+).*\/.*):/
    # and some didn't have the ':' or an action
    re_package_entry2 = /^(([\w+-]+).*\/.*\.t[gbx]z)/
    # combine them
    RE_PACKAGE_ENTRY = Regexp.union(re_package_entry0, re_package_entry1, re_package_entry2)

    # (* Security fix *)
    RE_SECURITY_FIX = /\(\*\s+security\s+fix\s+\*\)/i

    # for hacks sake, make these usbable elsewhere
    def self::re_date ; RE_DATE ; end
    def self::re_changelog_break ; RE_CHANGELOG_BREAK ; end
    def self::re_package_entry ; RE_PACKAGE_ENTRY ; end
    def self::re_security_fix ; RE_SECURITY_FIX ; end

    # A changeset, which should consist of entries of changes and/or notes
    # regarding the updates
    class Update
      # FIXME this class needs more proper value setting
      def initialize(date = nil,
                     notes = "",
                     entries = Array.new,
                     changelog = nil )
        @date = date
        @notes = notes
        @entries = entries
        @changelog = changelog
      end
      def date; @date; end
      def notes; @notes; end
      def entries; @entries; end
      def security; @entries.select {|e| e if e.security }; end
      def security?; @entries.select {|e| e.security }.first; end

      def date=(timestamp)
        if (timestamp.is_a?(Time))
          @date = timestamp
        elsif (timestamp.is_a?(Date))
          @date = timestamp.to_time
        else
          @date = Time.parse(timestamp)
        end
      end
      def notes=(text); @notes = text; end
      def changelog=(changelog); @changelog = changelog if changelog.is_a?(Slackware::ChangeLog); end
    end

    # The class for each item in a change set
    class Entry
      def initialize(package = nil,
                     section = nil,
                     action = nil,
                     notes = "",
                     security = false,
                     update = nil)
        @package  = package
        @section  = section
        @action   = action
        @notes = notes.is_a?(String) ? notes : ""
        @security = security == true
        @update = update
      end

      def package; @package; end
      def section; @section; end
      def action; @action; end
      def notes; @notes; end
      def security; @security; end
      def date; @update ? @update.date: nil;end

      def package=(package_name); @package = package_name ; end
      def section=(section_name); @section = section_name ; end
      def action=(action_name); @action = action_name ; end
      def update=(update); @update = update if update.is_a?(Slackware::ChangeLog::Update) ; end
      def notes=(notes_txt)
        @notes = notes_txt.is_a?(String) ? notes_txt : ""
      end
      def security=(bool)
        @security = bool == true
      end
    end

    def initialize(file = nil)
      @file     = file
      @strio    = StringIO.new
      @updates  = Array.new
    end

    def file; @file; end
    def updates; @updates; end

    # Returns the latest update in the set
    def latest 
      sort().last
    end
    def sort 
      @updates.sort {|x,y| x.date <=> y.date }
    end

    # All entries in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def entries
      @updates.map {|u| u.entries.map {|e| e } }.flatten
    end

    # All security in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def security
      @updates.map {|u| u.entries.select {|e| e if e.security } }.flatten
    end

    # All packages removed in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def pkgs_removed
      @updates.map {|u| u.entries.select {|e| e  if e.action == "Removed" } }.flatten
    end

    # All packages added in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def pkgs_added
      @updates.map {|u| u.entries.select {|e| e if e.action == "Added" } }.flatten
    end

    # All packages upgraded in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def pkgs_upgraded
      @updates.map {|u| u.entries.select {|e| e if e.action == "Upgraded" } }.flatten
    end

    # All packages rebuilt in this Slackware::ChangeLog
    #
    # Returns an Array of Slackware::ChangeLog::Entry
    def pkgs_rebuilt
      @updates.map {|u| u.entries.select {|e| e if e.action == "Rebuilt" } }.flatten
    end
    def parse(opts = {:file => nil, :data => nil})
      if not(opts[:file].nil?)
        @updates = parse_this_file(opts[:file]).updates
      elsif not(@file.nil?)
        @updates = parse_this_file(@file).updates
      end
      return self
    end

    # Class method
    class << self
      def parse(file)
        cl = ChangeLog.new(file)
        return cl.parse()
      end
      alias_method :open, :parse
    end

    def inspect
      "#<%s:0x%x @file=%s, %d @updates, %d @entries>" % [self.class.name, self.object_id.abs, self.file || '""', self.updates.count || 0, self.entries.count || 0]
    end

    protected
    # Parse order is something like:
    # * if its' a date match, store the date
    # * take change notes until
    # * package match on name and action
    # * set @security if present
    # * take packge notes until
    # * next package or entry separator
    # * separator creates next change entry
    def parse_this_file(file)
      f_handle = ""
      if file.is_a?(File)
        f_handle = file
      elsif file.is_a?(String)
        if File.exist?(File.expand_path(file))
          f_handle = File.open(File.expand_path(file))
        else
          raise StandardError.new("file not found\n")
        end
      else
        raise StandardError.new("file not found\n")
      end

      # Start our changelog
      changelog = ChangeLog.new(f_handle)
      f_handle.each do |line|
        if (line =~ RE_DATE)
          update = Update.new(Time.parse($1))

          # Tying this Slackware::ChangeLog::Update to it's Slackware::ChangeLog parent
          update.changelog = changelog
          while true
            if (f_handle.eof?)
              break
            end

            # take the next line
            u_line = f_handle.readline
            if (u_line =~ RE_CHANGELOG_BREAK)
              break
            end

            # the intimate iteration
            # Match is more expensive than =~,
            # but ruby-1.8.x is lossing the matched values down below
            # so this works on both ...
            if (match = RE_PACKAGE_ENTRY.match(u_line))
              u_entry = Entry.new()

              # tying this entry to it's Slackware::ChangeLog::Update parent
              u_entry.update = update

              # This silly iteration catches the different cases of 
              # which package line, matches which Regexp. WIN
              if match[1].nil?
                if match[4].nil?
                  u_entry.package = match[6] unless match[6].nil?
                else
                  u_entry.package = match[4]
                end
              else
                u_entry.package = match[1]
              end
              if u_entry.package.include?("/")
                u_entry.package = u_entry.package.split("/")[-1]
              end
              if match[2].nil?
                if match[5].nil?
                  u_entry.section = match[7] unless match[7].nil?
                else
                  u_entry.section = match[5]
                end
              else
                u_entry.section = match[2]
              end
              # set the action for the item, if it's present
              u_entry.action = match[3] unless match[3].nil?

              # Add this entry to the stack
              update.entries << u_entry
            else
              # if update.entries is empty, then this text is notes 
              # for the upate, else it is notes, for the entry
              if (update.entries.empty?)
                update.notes = update.notes + u_line
              else
                # if this line of the entry security fix, toggle the bool
                if (u_line =~ RE_SECURITY_FIX)
                  update.entries[-1].security = true
                end
                update.entries[-1].notes = update.entries[-1].notes + u_line
              end
            end
          end

          # Add this update to the stack
          changelog.updates << update
        end
      end

      # Give them their change set
      return changelog
    end # def self::parse_this_file

  end # class ChangeLog
end # module Slackware

# vim : set sw=2 sts=2 et :
