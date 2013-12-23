require 'pg'
require 'rss'
require 'uri'
require_relative 'models'

def add_feed(f)
	begin
		feed = RSS::Parser.parse(f)
		case feed.feed_type
			when 'rss'
				Feed.create(:name => feed.channel.title, :url => f)
			when 'rss'
				Feed.create(:name => feed.title, :url => f)
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
		add_feed(arg)
	else
		puts "Neither a valid file, nor a valid url"
	end
end
