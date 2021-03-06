#!usr/bin/env ruby

require File.dirname(File.expand_path(__FILE__))+'/../lib/rawline'

puts "*** Rawline Editor Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press CTRL+G to clear command history"
puts " * Press CTRL+D for line-related information"
puts " * Press CTRL+E to view command history"

editor = RawLine::Editor.new

editor.bind(:ctrl_g) { editor.clear_history }
editor.bind(:ctrl_d) { editor.debug_line }
editor.bind(:ctrl_e) { editor.show_history }
editor.bind(:ctrl_x) { puts; puts "Exiting..."; exit }

editor.completion_proc = lambda do |word|
	if word
		['select', 'update', 'delete', 'debug', 'destroy'].find_all	{ |e| e.match(/^#{Regexp.escape(word)}/) }
	end
end

loop do
	puts "You typed: [#{editor.read("=> ", true)}]"
end
