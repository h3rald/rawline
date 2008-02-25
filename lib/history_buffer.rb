#!/usr/bin/ruby

module InLine

	class HistoryBuffer < Array

		attr_reader :position, :size

		def initialize(size)
			@size = size
			@position = nil
		end

		def get
			return nil unless self.length > 0
			@position = self.length-1 unless @position
			self[@position]
		end

		def back
			return nil unless self.length > 0
			case @position
			when nil: @position = self.length-1
			when 0: nil
			else @position -= 1
			end
		end

		def forward
			return nil unless self.length > 0
			case @position
			when nil: @position = self.length-1
			when self.length-1: nil
			else @position += 1
			end
		end

		def resize(new_size)
			if new_size < @size
				@size-new_size.times { self.pop }
			end
			@size = new_size
			@position = nil
		end

		def <<(item)
			if @position then
				if item != self[@position] then
					# overwrite history element and delete successors
					self[@position] = item
					(self.length-@position-1).times { self.pop } 
				end
			else
				if @size <= self.length
					self.reverse!.pop 
					self.reverse!
				end
				self.push(item)
			end
			@position = nil
		end

	end

end
