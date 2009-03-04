#!usr/bin/env ruby

require 'rush'
require File.dirname(File.expand_path(__FILE__))+'/../lib/rawline'

class RawlineRush < Rush::Shell

	def initialize
		Rawline.basic_word_break_characters = "" 
		Rawline.completion_proc = completion_proc
		super
	end

	def run
		loop do
			cmd = Rawline.readline('rawline_rush> ')
			finish if cmd.nil? or cmd == 'exit'
			next if cmd == ""
			Rawline::HISTORY.push(cmd)
			execute(cmd)
		end
	end
end

shell = RawlineRush.new.run

