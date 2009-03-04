#!usr/bin/env ruby

require File.dirname(File.expand_path(__FILE__))+'/../lib/rawline'

puts "*** Readline emulation Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press <TAB> for file completion"

Rawline.editor.bind(:ctrl_x) { puts; puts "Exiting..."; exit }

Dir.chdir '..'

include Rawline

loop do
	puts "You typed: [#{readline("=> ", true)}]"
end
