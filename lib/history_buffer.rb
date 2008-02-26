#!/usr/bin/ruby

module InLine

	class HistoryBuffer < Array

		attr_reader :position, :size

		alias clear_array clear
		alias add <<

		def initialize(size)
			@size = size
			@position = nil
		end

		def resize(new_size)
			if new_size < @size
				@size-new_size.times { pop }
			end
			@size = new_size
			@position = nil
		end
		
		def clear
			@position = nil
			clear_array
		end

		def get
			return nil unless length > 0
			@position = length-1 unless @position
			at @position
		end

		def end?
			@position == length-1
		end

		def start?
			@position == 0
		end

		def back
			return nil unless length > 0
			case @position
			when nil: @position = length-1
			when 0: nil
			else @position -= 1
			end
		end

		def forward
			return nil unless length > 0
			case @position
			when nil: @position = length-1
			when length-1: nil
			else @position += 1
			end
		end

		def <<(item)
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
