#!/usr/bin/env ruby
# http://en.wikibooks.org/wiki/Ruby_Programming/Unit_testing

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

class TestChangeLog < Test::Unit::TestCase
  def setup
    @changlog_file = File.dirname(File.expand_path(__FILE__)) + "/samples/ChangeLog.txt"
    @changelog = Slackware::ChangeLog.new()
  end

  def teardown
  end

  def test_new_changelog_empty
    c = Slackware::ChangeLog.new()
    assert_not_nil(c)
    c = nil
  end
  def test_new_changelog_file
    c = Slackware::ChangeLog.new(:file => @changlog_file)
    assert_not_nil(c)
    c = nil
  end
  def test_open_changelog
    c = Slackware::ChangeLog.open(@changlog_file)
    assert_not_nil(c)
    c = nil
  end
  def test_new_changelog_update_empty
    c = Slackware::ChangeLog::Update.new()
    assert_not_nil(c)
    c = nil
  end
  def test_new_changelog_entry_empty
    c = Slackware::ChangeLog::Entry.new()
    assert_not_nil(c)
    c = nil
  end

  # testing constants
  def test_abbr_daynames
    assert(Slackware::ChangeLog::ABBR_DAYNAMES.count == 7)
  end
  def test_abbr_monthnames
    assert(Slackware::ChangeLog::ABBR_MONTHNAMES.count == 12)
  end
  def test_re_date
    assert(Slackware::ChangeLog::RE_DATE.class == Regexp)
  end
  def test_re_changelog_break
    assert(Slackware::ChangeLog::RE_CHANGELOG_BREAK.class == Regexp)
  end
  def test_re_package_entry
    assert(Slackware::ChangeLog::RE_PACKAGE_ENTRY.class == Regexp)
  end
  def test_re_security_fix
    assert(Slackware::ChangeLog::RE_SECURITY_FIX.class == Regexp)
  end

  # testing the methods
  def test_method_file
    assert_respond_to(@changelog, :file)
  end
  def test_method_updates
    assert_respond_to(@changelog, :updates)
  end
  def test_method_entries
    assert_respond_to(@changelog, :entries)
  end
  def test_method_security
    assert_respond_to(@changelog, :security)
  end
  def test_method_pkgs_removed
    assert_respond_to(@changelog, :pkgs_removed)
  end
  def test_method_pkgs_added
    assert_respond_to(@changelog, :pkgs_added)
  end
  def test_method_pkgs_upgraded
    assert_respond_to(@changelog, :pkgs_upgraded)
  end
  def test_method_pkgs_rebuilt
    assert_respond_to(@changelog, :pkgs_rebuilt)
  end
  def test_method_parse
    assert_respond_to(@changelog, :parse)
  end
  def test_method_inspect
    assert_respond_to(@changelog, :inspect)
  end

end

class TestChangeLogUpdate < Test::Unit::TestCase
  def setup
    @update = Slackware::ChangeLog::Update.new()
  end
  def teardown
    @update = nil
  end

  def test_method_date
    assert_respond_to(@update, :date)
  end
  def test_method_notes
    assert_respond_to(@update, :notes)
  end
  def test_method_entries
    assert_respond_to(@update, :entries)
  end

  def test_method_date_eq
    assert_respond_to(@update, :date=)
  end
  def test_method_notes_eq
    assert_respond_to(@update, :notes=)
  end

end

class TestChangeLogEntry < Test::Unit::TestCase
  def setup
    @entry = Slackware::ChangeLog::Entry.new()
  end
  def teardown
    @entry = nil
  end

  def test_method_package
    assert_respond_to(@entry, :package)
  end
  def test_method_section
    assert_respond_to(@entry, :section)
  end
  def test_method_action
    assert_respond_to(@entry, :action)
  end
  def test_method_notes
    assert_respond_to(@entry, :notes)
  end
  def test_method_security
    assert_respond_to(@entry, :security)
  end

  def test_method_package_eq
    assert_respond_to(@entry, :package=)
  end
  def test_method_section_eq
    assert_respond_to(@entry, :section=)
  end
  def test_method_action_eq
    assert_respond_to(@entry, :action=)
  end
  def test_method_notes_eq
    assert_respond_to(@entry, :notes=)
  end
  def test_method_security_eq
    assert_respond_to(@entry, :security=)
  end
end

# vim : set sw=2 sts=2 et :
