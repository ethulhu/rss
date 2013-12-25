require 'pg'
require 'rss'
require 'colorize'
require 'uri'
require_relative 'models'

def howto
	return <<eos
Fetch new posts
usage: rss update
eos
end

def strip_uri(str)
	# uri = URI.parse(str)
	# clean_key_vals = URI.decode_www_form(uri.query).reject{|k, _| k.start_with?('utm_')}
	# uri.query = URI.encode_www_form(clean_key_vals)
	# return uri.to_s
	return str.gsub(/&?utm_.+?(&|$)/, '').gsub(/\?$/,'')
end

def update(config)
	ActiveRecord::Base.establish_connection(config["db"])

	new = 0

	feeds = Feed.all
	size = feeds.max_by {|f| f.url.length}.url.length
	feeds.each do |feed|
		printf "%-#{size}s ", feed.url
		begin
			open(feed.url) do |rss|
				rss_feed = RSS::Parser.parse(rss,do_validate=false)
				case rss_feed.feed_type
				when 'rss'
					rss_feed.items.each do |post|
						begin
							Post.create(:title => post.title, :url => strip_uri(post.link || post.guid.content), :body => post.description, :unread => true)
							new = new + 1
						rescue ActiveRecord::RecordNotUnique
						end
					end
				when 'atom'
					rss_feed.entries.each do |post|
						begin
							Post.create(:title => post.title.content, :url => strip_uri(post.link.href), :body => post.content, :unread => true)
							new = new + 1
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
	puts "#{new} new items"
end
