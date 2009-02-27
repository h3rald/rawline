#!usr/bin/env ruby

#
#	line.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module RawLine
	
	# 
	# The Line class is used to represent the current line being processed and edited
	# by RawLine::Editor. It keeps track of the characters typed, the cursor position, 
	# the current word and maintains an internal history to allow undos and redos.
	#
	class Line

		attr_accessor :text, :position, :history, :prompt, :history_size, :word_separator
		attr_reader :offset

		include HighLine::SystemExtensions

		# 
		# Create an instance of RawLine::Line.
		# This method takes an optional block used to override the 
		# following instance attributes:
		# * <tt>@text</tt> - the line text.
		# * <tt>@history_size</tt> - the size of the line history buffer.
		# * <tt>@position</tt> - the current cursor position within the line.
		# * <tt>@prompt</tt> - a prompt to prepend to the line text.
		#
		def initialize(history_size)
			@text = ""
			@history_size = history_size
			@position = 0
			@prompt = ""
			@word_separator = ' '
			yield self if block_given?
			@history = RawLine::HistoryBuffer.new(@history_size)
			@history << "" # Add empty line for complete undo...
			@offset = @prompt.length
		end

		# 
		# Return the maximum line length. By default, it corresponds to the terminal's 
		# width minus the length of the line prompt.
		#
		def max_length
			terminal_size[0]-@offset
		end

		# 
		# Return information about the current word, as a Hash composed by the following
		# elements:
		# * <tt>:start</tt>: The position in the line corresponding to the word start
		# * <tt>:end</tt>: The position in the line corresponding to the word end
		# * <tt>:text</tt>: The word text.
		def word
			last = @text.index(@word_separator, @position)
			first = @text.rindex(@word_separator, @position)
			# Trim word separators and handle EOL and BOL
			if first then
			 	first +=1 
			else 
				first = bol
			end
			if last then
			 	last -=1 
			else 
				last = eol+1 unless last
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

		#
		# Return an array containing the words present in the current line
		#
		def words
			@text.split @word_separator
		end

		# 
		# Return the position corresponding to the beginning of the line.
		#
		def bol
		 0	
		end

		# 
		# Return true if the cursor is at the beginning of the line.
		#
		def bol?
			@position<=bol
		end
		
		# 
		# Return the position corresponding to the end of the line.
		#
		def eol
			@text.length-1
		end

		# 
		# Return true if the cursor is at the end of the line.
		#
		def eol?
			@position>=eol
		end

		# 
		# Decrement the line position by <tt>offset</tt>
		#
		def left(offset=1)
			@position = (@position-offset <= 0) ? 0 : @position-offset
		end

		# 
		# Increment the line position by <tt>offset</tt>
		#
		def right(offset=1)
			@position = (@position+offset >= max_length) ? max_length : @position+offset
		end

		# 
		# Add a character (expressed as a character code) to the line text.
		#
		def <<(char)
			@text << char.chr
		end

		#
		# Access the line text at <tt>@index</tt>
		#
		def [](index)
			@text[index]
		end

		#
		#  Modify the character(s) in the line text at <tt>@index</tt>
		#
		def []=(index, chars)
			@text[index] = chars
		end

		#
		# Return the length of the line text.
		#
		def length
			@text.length
		end

	end
end
