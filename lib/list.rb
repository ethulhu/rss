require 'pg'
require 'colorize'
require_relative 'models'

def howto
	return <<eos
Lists the set of feeds
usage: rss list
eos
end

def list(config)
	ActiveRecord::Base.establish_connection(config["db"])
	feeds = Feed.all
	size = feeds.max_by {|f| f.name.length}.name.length
	feeds.each do |feed|
		printf "%-#{size}s %s\n", feed.name, feed.url.cyan
	end
end
