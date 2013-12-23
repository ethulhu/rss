require 'pg'
require 'active_record'
require 'rss'
require 'reverse_markdown'
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

posts = Post.where(:unread => true)
posts.length.times do |i|
	post = posts[i]
	puts "#{i}: #{post.title} - #{post.url}"
end

i1,i2 = [nil,nil]
while true
	print ":"
	str = gets
	break if str.nil?

	command, *args = str.split(' ')
	if args.length > 1
	end

	case args.length
	when 0
		if i1.nil? or i2.nil?
			puts "Usage: (d|u|p) (int|range)"
			next
		end
	when 1
		i1,*i2 = args[0].split('-')
		case i2.length
			when 0
				i2 = i1
			when 1
				i2 = i2[0]
			else
				puts "Usage: (d|u|p) (int|range)"
				next
		end
		i1,i2 = [i1,i2].map { |i| i.strip.to_i }
	else
		puts "Usage: (d|u|p) (int|range)"
		next
	end

	case command
	when 'd'
		(i1..i2).each do |i|
			posts[i].update_attribute(:unread,false)
			puts "Post \"#{posts[i].title}\" marked unread"
		end
	when 'u'
		(i1..i2).each do |i|
			posts[i].update_attribute(:unread,true)
			puts "Post \"#{posts[i].title}\" marked unread"
		end
	when 'p'
		(i1..i2).each do |i|
			puts "#{posts[i].title} (#{posts[i].url})"
			puts posts[i].title.gsub(/./,"=")
			puts ""
			puts ReverseMarkdown.parse(posts[i].body)
		end
	else
		puts "Usage: (d|u|p) (int|range)"
		next
	end

end
