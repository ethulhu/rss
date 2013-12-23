require 'pg'
require 'rss'
require 'reverse_markdown'
require 'colorize'
require_relative 'models'

class UsageError < Exception
end

def parse_args(args)
	if args.empty?
		return nil
	end
	out = args.map do |str|
		i1,*i2 = str.split('-')
		case i2.length
		when 0
			[i1.to_i]
		when 1
			i1,i2 = [i1,i2[0]].map(&:to_i).sort
			(i1..i2).to_a
		else
			raise UsageError
		end
	end
	return out.flatten
end

def get_posts
	return Post.where(:unread => true)
end

def print_posts(posts)
	system "clear" unless system "cls"
	posts.length.times do |i|
		post = posts[i]
		puts "#{i.to_s.red}: #{post.title} - #{post.url.cyan}"
	end
end

def show(config)
	ActiveRecord::Base.establish_connection(config["db"])

	posts = get_posts
	print_posts(posts)

	selected = nil
	while true
		print ":"
		str = STDIN.gets
		break if str.nil?

		command, *args = str.split(' ')

		begin
			case command
			when 'q'
				break
			when 'r'
				posts = get_posts
				print_posts(posts)
			when /[dup]/
				selected = parse_args(args)
				raise UsageError if selected.nil? or selected.empty?
				case command
				when 'd'
					selected.each do |i|
						posts[i].update_attribute(:unread,false)
						puts "\"#{posts[i].title}\" marked as read."
					end
				when 'u'
					selected.each do |i|
						posts[i].update_attribute(:unread,true)
						puts "\"#{posts[i].title}\" marked unread."
					end
				when 'p'
					selected.each do |i|
						puts "#{posts[i].title} (#{posts[i].url})"
						puts posts[i].title.gsub(/./,"=")
						puts ""
						puts ReverseMarkdown.parse(posts[i].body)
					end
				end
		else
			raise UsageError
		end
	rescue UsageError
		puts "Usage: (d|u|p) (int|range)"
		next
	end

end
end
