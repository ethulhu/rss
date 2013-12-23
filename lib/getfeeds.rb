require 'pg'
require 'rss'
require 'colorize'
require 'uri'
require_relative 'models'

def strip_uri(str)
	return str.gsub(/&?utm_.+?(&|$)/, '').gsub(/\?$/,'')
end

def update(config)
	ActiveRecord::Base.establish_connection(config["db"])

	feeds = Feed.all
	feeds.each do |feed|
		print "#{feed.url} "
		begin
			open(feed.url) do |rss|
				rss_feed = RSS::Parser.parse(rss,do_validate=false)
				case rss_feed.feed_type
				when 'rss'
					rss_feed.items.each do |post|
						begin
							Post.create(:title => post.title, :url => strip_uri(post.link || post.guid.content), :body => post.description, :unread => true)
						rescue ActiveRecord::RecordNotUnique
						end
					end
				when 'atom'
					rss_feed.entries.each do |post|
						begin
							Post.create(:title => post.title.content, :url => strip_uri(post.link.href), :body => post.content, :unread => true)
						rescue ActiveRecord::RecordNotUnique
						end
					end
				end
			end
			puts "OK!".cyan
		rescue OpenURI::HTTPError => e
			puts e.message.red
		end
	end
end
