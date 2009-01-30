#!/usr/local/bin/ruby -w

require 'rubygems'
require 'highline/system_extensions'

include HighLine::SystemExtensions

puts "Press a key to view the corresponding ASCII code(s) (or CTRL-X to exit)."

loop do

	print "=> "
	char = get_character
	case char
	when ?\C-x: puts "Exiting..."; exit;
	else puts "#{char.chr} [#{char}] (hex: #{char.to_s(16)})";
	end
	
end
