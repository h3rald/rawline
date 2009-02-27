#!usr/bin/env ruby

require File.dirname(File.expand_path(__FILE__))+'/../lib/rawline'

include Rawline

puts "*** Readline emulation Test Shell ***"
puts " * Press CTRL+X to exit"
puts " * Press <TAB> for file completion"

rawline_editor.bind(:ctrl_x) { puts; puts "Exiting..."; exit }

Dir.chdir '..'

loop do
	puts "You typed: [#{readline("=> ", true).chomp!}]"
end
