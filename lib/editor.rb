#!/usr/bin/ruby

module Inline

	class Editor

		include HighLine::SystemExtensions
		include SystemExtensions
		include Mappings
		include Actions

		def self.line
			@@line
		end

		def self.line=(l)
			@@line = l
		end

		def self.clear_line
			@@line.text = ''
			@@line.position = 0
		end

		def self.char
			@@char
		end

		def self.char=(c)
			@@char = c
		end

		def self.history
			@@history
		end
		
		def self.history=(h)
			@@history = h
		end

		def initialize(keyboard=nil)
			@@history = InLine::HistoryBuffer.new(MAX_HISTORY_ITEMS)
			@@char = nil
			@keyboard = keyboard || KeyBoard.new
			@newline = true
		end

		def read(prompt="", input=STDIN)
			@newline = true
			@@line = Line.new(prompt)
			add_to_line_history
			loop do
				print prompt if @newline
				@newline = false
				@@char = get_character(input)
				if @keyboard.bound?:	@keyboard.press
				else default_action
				end
				break if @@char == ENTER
			end
			puts
			@@line
		end

		def bind(key, &block)
			@keyboard.bind(char, block)
		end


	end
end


