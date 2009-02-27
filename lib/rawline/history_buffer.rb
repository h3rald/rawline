#!usr/bin/env ruby

#
#	history_buffer.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#
#
#
module RawLine

	# 
	# The HistoryBuffer class is used to hold the editor and line histories, as well
	# as word completion matches.
	#
	class HistoryBuffer < Array

		attr_reader :position, :size
		attr_accessor :duplicates, :exclude, :cycle

		undef <<

		#
		# Create an instance of RawLine::HistoryBuffer. 
		# This method takes an optional block used to override the 
		# following instance attributes:
		# * <tt>@duplicates</tt> - whether or not duplicate items will be stored in the
		# buffer.
		# * <tt>@exclude</tt> - a Proc object defining exclusion rules to prevent items
		# from being added to the buffer.
		# * <tt>@cycle</tt> - Whether or not the buffer is cyclic.
		#
		def initialize(size)
			@duplicates = true
			@exclude = lambda{|a|}
			@cycle = false
			yield self if block_given?
			@size = size
			@position = nil
		end

		#
		# Resize the buffer, resetting <tt>@position</tt> to nil.
		#
		def resize(new_size)
			if new_size < @size
				@size-new_size.times { pop }
			end
			@size = new_size
			@position = nil 
		end
		
		# 
		# Clear the content of the buffer and reset <tt>@position</tt> to nil.
		#
		def empty
			@position = nil 
			clear
		end

		# 
		# Retrieve the element at <tt>@position</tt>.
		#
		def get
			return nil unless length > 0
			@position = length-1 unless @position
			at @position
		end

		# 
		# Return true if <tt>@position</tt> is at the end of the buffer.
		#
		def end?
			@position == length-1
		end

		# 
		# Return true if <tt>@position</tt> is at the start of the buffer.
		#
		def start?
			@position == 0
		end

		#
		# Decrement <tt>@position</tt>.
		#
		def back
			return nil unless length > 0
			case @position
			when nil then
				@position = length-1
			when 0 then
			 	@position = length-1 if @cycle
			else 
				@position -= 1
			end
		end

		#
		# Increment <tt>@position</tt>.
		#
		def forward
			return nil unless length > 0
			case @position
			when nil then
				@position = length-1
			when length-1 then
			 	@position = 0 if @cycle
			else 
				@position += 1
			end
		end

		# 
		# Add a new item to the buffer.
		#
		def <<(item)
			delete(item) unless @duplicates
			unless @exclude.call(item)
				# Remove the oldest element if size is exceeded
				if @size <= length
					reverse!.pop 
					reverse!
				end
				# Add the new item and reset the position
				push(item)
				@position = nil 
			end
		end

	end

end
