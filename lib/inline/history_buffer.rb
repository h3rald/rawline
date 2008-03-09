#!/usr/local/bin/ruby -w

module InLine

	class HistoryBuffer < Array

		attr_reader :position, :size
		attr_accessor :duplicates, :exclude, :cycle

		undef <<

		def initialize(size)
			@duplicates = true
			@exclude = lambda { nil }
			@cycle = false
			yield self if block_given?
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
		
		def empty
			@position = nil 
			clear
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
			when 0: @position = length-1 if @cycle
			else @position -= 1
			end
		end

		def forward
			return nil unless length > 0
			case @position
			when nil: @position = length-1
			when length-1: @position = 0 if @cycle
			else @position += 1
			end
		end

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
