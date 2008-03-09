#!/usr/local/bin/ruby -w

module InLine
	
	class WindowsTerminal < Terminal

		def initialize
			super
			@escape_codes = [0, 0xE0]
			@keys.merge!(
				{
					:left_arrow => [0xE0,0x4B],
					:right_arrow => [0xE0,0x4D],
					:up_arrow => [0xE0,0x48],
					:down_arrow => [0xE0,0x50],
					:insert => [0xE0,0x52],
					:delete => [0xE0,0x53],
					:backspace => [8],
					:enter => [?\r]
				})
		end

	end


end
