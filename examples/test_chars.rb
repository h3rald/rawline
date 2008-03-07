#!/usr/bin/ruby

require 'rubygems'
require 'highline/system_extensions'

include HighLine::SystemExtensions

puts "Press a key to view the corresponding ASCII code (or CTRL-X to exit)."

loop do

	print "=> "
	char = get_character
	case char
	when ?\C-x: print "Exiting..."; exit;
	else puts "[#{char}] (hex: #{char.to_s(16)})";
	end
	
end
