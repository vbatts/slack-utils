require 'rss/maker'
require 'slackware/changelog'

module Slackware
  class ChangeLog
    def to_rss
      version = "2.0" # ["0.9", "1.0", "2.0"]
      content = RSS::Maker.make(version) do |m|
        m.channel.title = "Example Ruby RSS feed"
        m.channel.link = "http://www.slackware.com"
        m.channel.description = "Old news (or new olds) at Ruby RSS"
        m.items.do_sort = true # sort items by date

        i = m.items.new_item
        i.title = "Ruby can parse RSS feeds"
        i.link = "http://www.rubyrss.com/"
        i.date = Time.parse("2007/2/11 14:01")

        i = m.items.new_item
        i.title = "Ruby can create RSS feeds"
        i.link = "http://www.rubyrss.com/"
        i.date = Time.now
      end
      return content
    end
  end
end



