#!/usr/bin/env ruby

require 'rubygems'
require 'highline/system_extensions'

include HighLine::SystemExtensions

puts "Press a key to view the corresponding ASCII code(s) (or CTRL-X to exit)."

loop do

	print "=> "
	char = get_character.ord rescue nil
	case char
	when ?\C-x.ord then
	 	puts "Exiting..."; exit;
	else 
		puts "#{char.chr} [#{char}] (hex: #{char.to_s(16)})";
	end
	
end
