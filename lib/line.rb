#!/usr/bin/ruby

module Inline
	
	class Line
		
		include HighLine::SystemExtensions

		attr_accessor :text, :length, :position, :max_length, :history
		attr_reader :offset, :prompt

		def initialize(prompt="",line="")
			@text = line
			@history = HistoryBuffer.new(MAX_UNDO_OPERATIONS)
			@position = 0
			@prompt = prompt
			@offset = prompt.length
		end

		def max_length
			terminal_size[0]-@offset
		end

		def bol
		 0	
		end

		def bol?
			@position<=bol
		end
		
		def eol
			@text.length-1
		end

		def eol?
			@position>=eol
		end

		def <(offset)
			@position = (@position-offset <= 0) ? 0 : @position-offset
		end

		def >(offset)
			@position = (@position+offset >= max_length) ? max_length : @position+offset
		end

		def <<(char)
			@text << char.chr
		end

		def [](index)
			@text[index]
		end

		def []=(index, chars)
			@text[index] = chars
		end

		def length
			@text.length
		end

	end
end
