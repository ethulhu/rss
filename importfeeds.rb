require 'pg'
require 'active_record'
require 'rss'
require 'json'

class Feed < ActiveRecord::Base
end

unless File.exist?("#{ENV["HOME"]}/.rssrc")
	puts "Needs configuration file at .rssrc"	
end
config = JSON.parse(File.read("#{ENV["HOME"]}/.rssrc"))

File.readlines(ARGV[0]).each do |f|
	begin
		puts f
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
