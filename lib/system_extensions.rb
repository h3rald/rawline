#!/usr/bin/ruby

module Inline
	module SystemExtensions

		def put_character(char, input = STDIN)
      Win32API.new("crtdll", "_putch", ["I"], "v").Call(char)
    end

	end
end
