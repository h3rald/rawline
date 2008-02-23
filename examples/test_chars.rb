#!/usr/bin/ruby

require 'highline/system_extensions'

include HighLine::SystemExtensions

puts "Press a key to view the corresponding ASCII code (or CTRL-X to exit)."

loop do

	print "=> "
	char = get_character
	case char
	when 24: print "Exiting..."; exit;
	else puts "[#{char}]";
	end
	
end
