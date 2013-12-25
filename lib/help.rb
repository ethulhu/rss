def help (config,name=nil)
		commands = Dir.entries(File.dirname(__FILE__)).map{|f| f.gsub(/\.rb$/,'')} - ['.','..','models','help']
		usage = "usage: rss help (#{commands.join('|')})"
	if name.nil?
		puts usage
	elsif ! commands.include?(name)
		puts "\"#{name}\" invalid"
		puts usage
	else
		require_relative name
		puts howto
	end
end
