#!/usr/bin/ruby

module Inline
	
	class Line
		
		include HighLine::SystemExtensions

		attr_accessor :text, :length, :offset, :position, :max_length

		def initialize(line="")
			@text = line
			@position = 0
		end

		def max_length
			terminal_size[0]
		end

		def bol?
			@position<=0
		end

		def eol?
			@position>=@text.length
		end

		def <(offset)
			@position = (@position-offset <= 0) ? 0 : @position-offset
		end

		def >(offset)
			@position = (@position+offset >= max_length) ? max_length : @position+offset
		end

		def <<(char)
			@text << char.chr
			self > 1
		end

		def [](index)
			@text[index]
		end

		def length
			@text.length
		end

	end
end
