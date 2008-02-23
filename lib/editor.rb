#!/usr/bin/ruby

module Inline

	class Editor

		include HighLine::SystemExtensions
		include SystemExtensions
		include Mappings
		include Actions

		
		def self.history
			@@history
		end

		def self.line
			@@line
		end

		def self.char
			@@char
		end

		def self.history=(h)
			@@history = h
		end

		def self.line=(l)
			@@line = l
		end

		def self.char=(c)
			@@char = c
		end

		def self.history_add(l)
			@@history << l
		end

		def self.history_get(i)
			@@history[i]
		end

	
		def initialize(keyboard=nil)
			@@history = []
			@@char = nil
			@@line = Line.new
			@keyboard = keyboard || KeyBoard.new
			@newline = true
		end

		def read(prompt="", input=STDIN)
			@newline = true
			loop do
				print prompt if @newline
				@newline = false
				@@line.offset = prompt.length
				@@char = get_character(input)
				if @keyboard.bound?:	@keyboard.press
				else default_action
				end
				break if @@char == ENTER
			end
			puts
		end

		def bind(key, &block)
			@keyboard.bind(char, block)
		end


	end
end


