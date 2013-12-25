require 'pg'
require 'rss'
require 'colorize'
require 'uri'
require 'thread'
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

	before = Post.count
	size = Feed.all.max_by {|f| f.url.length}.url.length
	queue = Queue.new
	Feed.all.each do |feed|
		queue << Proc.new do
			begin
				update_feeds(feed.url)
				printf "%-#{size}s %s\n", feed.url, "OK!".cyan
			rescue OpenURI::HTTPError => e
				printf "%-#{size}s %s\n", feed.url, e.message.red
			end
		end
	end
	threads = config["update"]["threads"] rescue nil
	pool = Array.new(threads || 5) do
		Thread.new do
			until queue.empty?
				p = queue.pop(non_blocking=false) rescue nil
				if p
					p.call
				end
			end
		end
	end
	pool.each {|t| t.join}
	puts "#{Post.count - before} new items"
end

def update_feeds(url)
	open(url) do |rss|
		rss_feed = RSS::Parser.parse(rss,do_validate=false)
		case rss_feed.feed_type
		when 'rss'
			rss_feed.items.each do |post|
				url = strip_uri(post.link || post.guid.content)
				unless Post.find_by(:url => url)
					Post.create(:title => post.title, :url => url, :body => post.description, :unread => true)
				end
			end
		when 'atom'
			rss_feed.entries.each do |post|
				url = strip_uri(post.link.href)
				unless Post.find_by(:url => url)
					Post.create(:title => post.title.content, :url => url, :body => post.content, :unread => true)
				end
			end
		end
	end
end
