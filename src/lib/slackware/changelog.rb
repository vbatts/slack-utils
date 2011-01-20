
require 'slackware/package'

module Slackware
  class ChangeLog
    def initialize(file = nil)
      @file = file
      @entries = Array.new
    end

    def file
      @file
    end
    def entries
      @entries
    end

    def self::parse(file)
      changelog = Hash.new
			changelog_date = File.read(file).split(/\n/)
			actions = %w{removed added upgraded rebuilt}
			actions.each {|action|
				changelog[:"#{action}"] = changelog_date.map {|line|
					if line =~ /^(\w+)\/(.*)\.t[gx]z:\s+#{action}\.?$/i
						s = Slackware::Package.parse($2)
						s.path = $1
						if (self.mirror.nil?)
							base_path= self.path
						else
							base_path= self.mirror + self.path
						end
						s.package_location = self.proto +
							base_path +
							"slackware" +
							self.arch +
							"-" +
							self.version +
							"/" 
						s
					end
				}.compact
			}
			return changelog
    end

    def inspect
      "#<%s:0x%x @file=%s, %d @entries>" % [self.class.name, self.object_id.abs, self.file || '""', self.entries.count || 0]
    end
  end
end
