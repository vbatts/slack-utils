require 'rss/maker'
require 'slackware/changelog'

module Slackware
  class ChangeLog
    # or maybe "http://connie.slackware.com/~msimons/slackware/grfx/shared/dobbslack1.jpg"
    IMAGE_URL = "http://connie.slackware.com/~msimons/slackware/grfx/shared/bluepiSW.jpg"
    def to_rss
      version = "2.0" # ["0.9", "1.0", "2.0"]
      content = RSS::Maker.make(version) do |m|
        added_title = ""
        if @opts[:arch]
          added_title = added_title + "slackware#{@opts[:arch]}"
        end
        if @opts[:version]
          added_title = added_title + "-#{@opts[:version]}"
        end

        if added_title.empty?
          m.channel.title = "Slackware ChangeLog.txt"
        else
          m.channel.title = "#{added_title} ChangeLog.txt"
        end
        if @opts[:url]
          m.channel.link = "%s#slackagg" % [@opts[:url]]
        else
          m.channel.link = "http://www.slackware.com/#slackagg"
        end
        m.channel.description = "a parsed ChangeLog.txt, is an extendable ChangeLog.txt"

	if @opts[:image_url]
          m.channel.logo = @opts[:image_url]
	else
          m.channel.logo = IMAGE_URL
	end
	image = m.image
	if @opts[:image_url]
          image.url = @opts[:image_url]
	else
	  image.url = IMAGE_URL
	end
	image.title = "Slackware Linux"
	image.width = "144"
	image.height = "144"

        m.items.do_sort = true # sort items by date

        @updates.each {|update|
          i = m.items.new_item
          # Add a plug to the title of the update, if it includes a security fix
          # set this here, so we don't have to .map again down below
          security = update.entries.map {|e| 1 if e.security }.compact.count
          if (security > 0)
            i.title = "%s (* Security fix *)" % [update.date.utc.to_s]
          else
            i.title = update.date.utc.to_s
          end
          if @opts[:url]
            i.link = "%s#%s" % [@opts[:url], update.date.to_i]
          else
            i.link = "http://slackware.com/#slackagg#%s" % [update.date.to_i]
          end
          i.date = update.date

          i.description = ""
          if (update.entries.count > 0)
            if (security > 0)
              i.description = i.description + "%d new update(s), %d security update(s)\n\n" % [update.entries.count, security]
            else
              i.description = i.description + "%d new update(s)\n\n" % [update.entries.count]
            end
          end
          i.description = i.description + "<pre><blockquote>\n"
          unless (update.notes.empty?)
              i.description = i.description + update.notes + "\n\n"
          end
          if (update.entries.count > 0)
            update.entries.each {|entry|
              if (entry.notes.empty?)
                i.description = i.description + sprintf("%s/%s:\s%s\n",
                                                        entry.section,
                                                        entry.package,
                                                        entry.action)
              else
                i.description = i.description + sprintf("%s/%s:\s%s\n\s\s%s\n",
                                                        entry.section,
                                                        entry.package,
                                                        entry.action,
                                                        entry.notes)
              end
            }
          end
          i.description = i.description + "</blockquote></pre>\n"
          i.description.gsub!(/\n/, "<br/>\n")
        }
      end
      return content
    end
  end
end



