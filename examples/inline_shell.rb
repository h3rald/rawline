#!/usr/bin/ruby

require '../lib/inline'
include InLine::Mappings

puts "*** Inline Editor Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press CTRL+C to clear command history"
puts " * Press CTRL+D for line-related information"
puts " * Press CTRL+E to view command history"

editor = InLine::Editor.new

editor.bind(CTRL_C) { editor.clear_history }
editor.bind(CTRL_D) { editor.debug_line }
editor.bind(CTRL_E) { editor.show_history }
editor.bind(CTRL_X) { puts; puts "Exiting..."; editor.quit }

editor.completion_proc = lambda do |word|
	if word
		['select', 'update', 'delete', 'debug', 'destroy'].find_all	{ |e| e.match(/^#{Regexp.escape(word)}/) }
	end
end

loop do
	editor.read("=> ")
end
