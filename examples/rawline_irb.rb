#!usr/bin/env ruby

require 'irb'
require 'irb/completion'
require File.dirname(File.expand_path(__FILE__))+'/../lib/rawline'

Rawline.basic_word_break_characters= " \t\n\"\\'`><;|&{(" 
Rawline.completion_append_character = nil
Rawline.completion_proc = IRB::InputCompletor::CompletionProc

class RawlineInputMethod < IRB::ReadlineInputMethod
	include Rawline
	def gets
		if l = readline(@prompt, false)
			HISTORY.push(l) if !l.empty?
			@line[@line_no += 1] = l + "\n"
		else
			@eof = true
			l
		end
	end
end

module IRB
	@CONF[:SCRIPT] = RawlineInputMethod.new
end
IRB.start
