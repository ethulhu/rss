require 'pg'
require 'rss'
require 'uri'
require_relative 'models'

def howto
	return <<eos
Imports feeds from args or a file
usage: rss import <url|file>
eos
end

def add_feed(f)
	url = f.strip
	begin
		feed = RSS::Parser.parse(url)
		case feed.feed_type
			when 'rss'
				Feed.create(:name => feed.channel.title, :url => url)
			when 'rss'
				Feed.create(:name => feed.title, :url => url)
		end
	rescue ActiveRecord::RecordNotUnique
	end
end

def import(config,arg)
	ActiveRecord::Base.establish_connection(config["db"])
	if File.exist?(arg)
		File.readlines(arg).each do |f|
			puts f
			add_feed(f)
		end
	elsif arg =~ /^#{URI::regexp}$/
		puts arg
		add_feed(arg)
	else
		puts "Neither a valid file, nor a valid url"
	end
end
