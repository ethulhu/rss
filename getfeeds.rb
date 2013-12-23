require 'pg'
require 'active_record'
require 'rss'
require 'json'

class Feed < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

unless File.exist?("#{ENV["HOME"]}/.rssrc")
	puts "Needs configuration file at .rssrc"	
end
config = JSON.parse(File.read("#{ENV["HOME"]}/.rssrc"))

ActiveRecord::Base.establish_connection(config["db"])

feeds = Feed.all
feeds.each do |feed|
	open(feed.url) do |rss|
		puts feed.url
		rss_feed = RSS::Parser.parse(rss,do_validate=false)
		case rss_feed.feed_type
			when 'rss'
				rss_feed.items.each do |post|
					begin
						Post.create(:title => post.title, :url => post.link || post.guid.content, :body => post.description, :unread => true)
					rescue ActiveRecord::RecordNotUnique
					end
				end
		when 'atom'
				rss_feed.entries.each do |post|
					begin
						Post.create(:title => post.title.content, :url => post.link.href, :body => post.content, :unread => true)
					rescue ActiveRecord::RecordNotUnique
					end
				end
		end
	end
end
