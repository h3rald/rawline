#!/usr/bin/ruby

module Inline
	
	class KeyBoard

		include Mappings
		include Actions
		include HighLine::SystemExtensions

		def initialize
			@keys = {}
			@key_pressed = nil
			default_key_bindings
		end

		def bound?
			@keys[Editor.char] ? true : false
		end

		def press
			@keys[Editor.char].call
		end

		def bind(char, &block)
			@keys[char] = block
		end
		
		private

		def default_key_bindings		
			bind(ENTER) { add_to_history }
			bind(CTRL_X) { exit_script }
			bind(BACKSPACE) { delete_left_character }
			bind(CTRL_K) { clear_line }
			bind(CTRL_D) { debug_line }
			bind(SPECIAL) do
				arrow_char = get_character(STDIN)
				case arrow_char
				when LEFT_ARROW: move_left
				when RIGHT_ARROW: move_right
				when DEL: delete_character
				else nil
				end
			end
		end
		
	end

end
