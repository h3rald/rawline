#!/usr/bin/ruby

module InLine
	
	class Line
		
		include HighLine::SystemExtensions

		attr_accessor :text, :length, :position, :max_length, :history, :prompt, :history_size, :word_separator
		attr_reader :offset

		def initialize(history_size)
			@text = ""
			@history_size = history_size
			@position = 0
			@prompt = ""
			@word_separator = ' '
			yield self if block_given?
			@words = []
			@history = InLine::HistoryBuffer.new(@history_size)
			@offset = @prompt.length
		end

		def max_length
			terminal_size[0]-@offset
		end

		def word
			last = @text.index(@word_separator, @position)
			first = @text.rindex(@word_separator, @position)
			# Trim word separators and handle EOL and BOL
			if first: first +=1 
			else first = bol
			end
			if last: last -=1 
			else last = eol+1 unless last
			end
			# Swap if overlapping
			last, first = first, last if last < first
			text = @text[first..last]
			# Repeat the search if within word separator
			if text.match @word_separator then
				last = first
				first = @text.rindex(@word_separator, first)
			 	if first then first+=1
				else first =	bol 
				end
				text = @text[first..last]
			end
			{:start => first, :end => last, :text => text}
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
