#!/usr/bin/ruby

module Inline
	module SystemExtensions

		def put_character(char, input = STDIN)
      Win32API.new("crtdll", "_putch", ["I"], "V").Call(char)
    end

		def raw_print(string)
			string.each_byte { |c| put_character c }
		end

	end
end
