#!/usr/local/bin/ruby -w

require File.dirname(File.expand_path(__FILE__))+'/../lib/inline'

puts "*** Inline Editor Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press CTRL+C to clear command history"
puts " * Press CTRL+D for line-related information"
puts " * Press CTRL+E to view command history"

editor = InLine::Editor.new

editor.bind(:ctrl_c) { editor.clear_history }
editor.bind(:ctrl_d) { editor.debug_line }
editor.bind(:ctrl_e) { editor.show_history }
editor.bind(:ctrl_x) { puts; puts "Exiting..."; exit }

editor.completion_proc = lambda do |word|
	if word
		['select', 'update', 'delete', 'debug', 'destroy'].find_all	{ |e| e.match(/^#{Regexp.escape(word)}/) }
	end
end

loop do
	puts "You typed: [#{editor.read("=> ").chomp!}]"
end
