#!/usr/bin/ruby

module InLine
	
	class VT220Terminal < Terminal

		def initialize
			super
			@escape_codes = [?\e]
			@keys.merge!(
				{
					:up_arrow => [?\e, ?[, ?A],
					:down_arrow => [?\e, ?[, ?B],
					:right_arrow => [?\e, ?[, ?C],
					:left_arrow => [?\e, ?[, ?D],
					:insert => [?\e, ?[, ?2, ?~],
					:delete => [?\e, ?[, ?3, ?~],
					:backspace => [?\C-?]
				})
		end

	end


end
