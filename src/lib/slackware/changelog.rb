# vim: set ts=2 sw=2 noexpandtab :

require 'slackware/package'

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
    RE_CHANGELOG_BREAK = Regexp.new(/^+--------------------------+$/)

    # The regular entry, accounting for usb-and-pxe-installers directory,
    # and notes after the action
    re_package_entry0 = Regexp.new(/^((\w+|-)+\/.*):\s+(\w+).*\.?$/)
    # Some didn't have an action after the name
    re_package_entry1 = Regexp.new(/^(\w+\/.*):/)
    # and some didn't have the ':' or an action
    re_package_entry2 = Regexp.new(/^(\w+\/.*\.t(g|b|x)z)/)
    # combine them
    RE_PACKAGE_ENTRY = Regexp.union(re_package_entry0, re_package_entry1, re_package_entry2)

    # (* Security fix *)
    RE_SECURITY_FIX = Regexp.new(/\(\*\s+security\s+fix\s+\*\)/i)

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
    end

    # The class for each item in a change set
    class Entry
      # FIXME this class needs more proper value setting
      def initialize(line = nil)
        @package = @action = @notes = nil
        @security = false
      end
      def package; @package; end
      def action; @action; end
      def notes; @notes; end
      def security; @security; end
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
        end
      else
        return -1
      end

      changelog = ChangeLog.new(f_handle)
      f_handle.each do |line|
        # XXX do some hot stuff here

      end

      return changelog
    end

    def inspect
      "#<%s:0x%x @file=%s, %d @entries>" % [self.class.name, self.object_id.abs, self.file.path || '""', self.entries.count || 0]
    end
  end
end
