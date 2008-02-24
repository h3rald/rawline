#!/usr/bin/ruby

module Inline

	class HistoryBuffer < Array

		def initialize(size)
			@size = size
			@position = nil
		end

		def back
			if @position == 0: self[0]
			else self[@position-1]
			end
		end

		def forward
			if @position == @size-1: self[@size-1]
			else self[@position+1]
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
			self.reverse.pop if @size <= self.length
			self.push(item)
		end

		private

		def [](index)
			i = (index <= @size-1) ? index : index-@size-1
			@position = i
			self[i]
		end

	end

end
