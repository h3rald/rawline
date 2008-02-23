#!/usr/bin/ruby

require '../lib/inline'

puts "*** Inline Editor Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press CTRL+D to line-related information"

$editor = Inline::Editor.new

loop do

	$editor.read("=> ")

end
