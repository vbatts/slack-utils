# vim: set ts=2 sw=2 noexpandtab :

require 'slackware/package'
require 'date'
require 'time'

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
    RE_DATE = Regexp.new(/^(#{re_daynames}\s+#{re_monthnames}\s+\d+\s+\d{2}:\d{2}:\d{2}\s\w+\s+\d+)$/)
 
    # This break has been the same as long as I can find
    RE_CHANGELOG_BREAK = Regexp.new(/^\+--------------------------\+$/)

    # The regular entry, accounting for usb-and-pxe-installers directory,
    # and notes after the action
    re_package_entry0 = Regexp.new(/^(([\w+-]+).*\/.*):\s+(\w+).*\.?$/)
    # Some didn't have an action after the name
    re_package_entry1 = Regexp.new(/^(([\w+-]+).*\/.*):/)
    # and some didn't have the ':' or an action
    re_package_entry2 = Regexp.new(/^(([\w+-]+).*\/.*\.t[gbx]z)/)
    # combine them
    RE_PACKAGE_ENTRY = Regexp.union(re_package_entry0, re_package_entry1, re_package_entry2)

    # (* Security fix *)
    RE_SECURITY_FIX = Regexp.new(/\(\*\s+security\s+fix\s+\*\)/i)

		# for hacks sake, make these usbable elsewhere
		def self::re_date ; RE_DATE ; end
		def self::re_changelog_break ; RE_CHANGELOG_BREAK ; end
		def self::re_package_entry ; RE_PACKAGE_ENTRY ; end
		def self::re_security_fix ; RE_SECURITY_FIX ; end

    # A changeset, which should consist of entries of changes and/or notes
    # regarding the updates
    class Update
      # FIXME this class needs more proper value setting
      def initialize(date = nil, notes = nil, entries = Array.new)
        @date = date
        @notes = notes
        @entries = entries
      end
      def date; @date; end
      def notes; @notes; end
      def entries; @entries; end

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
    end

    # The class for each item in a change set
    class Entry
      # FIXME this class needs more proper value setting
      def initialize(line = nil)
        @package = @section = @action = @notes = nil
        @security = false
      end
      def package; @package; end
      def section; @section; end
      def action; @action; end
      def notes; @notes; end
      def security; @security; end

      def package=(package_name); @package = package_name ; end
      def section=(section_name); @section = section_name ; end
      def action=(action_name); @action = action_name ; end
      def notes=(notes_txt); @notes = notes_txt ; end
      def security=(bool)
				if (bool == true)
					@secuity = bool
				else
					@security = false
				end
			end
    end

    def initialize(file = nil)
      @file = file
      @updates = Array.new
    end

    def file; @file; end
    def updates; @updates; end
    def entries
      @updates.map {|update| update.entries.map {|entry| {:date => update.date, :entry => entry } } }.flatten
    end

    # XXX parse order needs to be
    # * if its' a date match, store the date
    # * take change notes until
    # * package match on name and action
    # * set @security if present
    # * take packge notes until
    # * next package or entry separator
    # * separator creates next change entry
    def self::parse(file)
			f_handle = ""
      if file.is_a?(File)
				f_handle = file
      elsif file.is_a?(String)
        if File.exist?(File.expand_path(file))
          f_handle = File.open(File.expand_path(file))
				else
					return -1
        end
      else
        return -1
      end

      changelog = ChangeLog.new(f_handle)
      f_handle.each do |line|
				if (line =~ RE_DATE)
					u = Update.new(Time.parse($1))
					while true
						if (f_handle.eof?)
							break
						end

						# take the next line
						u_line = f_handle.readline
						if (u_line =~ RE_CHANGELOG_BREAK)
							break
						end

        		# XXX do some hot stuff here
						# still needs an until check for update notes, and entry notes
						if (u_line =~ RE_PACKAGE_ENTRY)
							u_entry = Entry.new()
							# This silly iteration catches the different cases of 
							# which package line, matches which Regexp. WIN
					    if $1.nil?
					      if $4.nil?
					        u_entry.package = $6 unless $6.nil?
					      else
					        u_entry.package = $4
					      end
					    else
					      u_entry.package = $1
					    end
							if u_entry.package.include?("/")
								u_entry.package = u_entry.package.split("/")[-1]
							end
					    if $2.nil?
					      if $5.nil?
					        u_entry.section = $7 unless $7.nil?
					      else
					        u_entry.section = $5
					      end
					    else
					      u_entry.section = $2
					    end
					    u_entry.action = $3 unless $3.nil?

							# Add this entry to the stack
							u.entries << u_entry
						end
					end

					# Add this update to the stack
					changelog.updates << u
				end
      end

			# Give them their change set
      return changelog
    end

    def inspect
      "#<%s:0x%x @file=%s, %d @updates, %d @entries>" % [self.class.name, self.object_id.abs, self.file || '""', self.updates.count || 0, self.entries.count || 0]
    end
  end
end
