#!/usr/bin/env ruby

$:.insert(0, File.expand_path(File.dirname(File.expand_path(__FILE__)) + "/../lib/"))

require 'test/unit'
require 'slackware'

class TestChangeLog < Test::Unit::TestCase
	def setup
		@changlog_file = File.dirname(File.expand_path(__FILE__)) + "/samples/ChangeLog.txt"
	end

	def teardown
	end

	def test_new_changelog_empty
		c = Slackware::ChangeLog.new()
		assert_not_nil(Slackware::UTILS_VERSION)
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
end


