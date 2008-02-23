#!/usr/bin/ruby

module Inline
	
	module Actions

		include Mappings
		include SystemExtensions

		def default_action
			unless mapped?
				print_character
			end
		end

		def print_character(char=Editor.char)
			unless Editor.line.length >= Editor.line.max_length
				put_character char
				Editor.line << Editor.char unless Editor.char == 224
			end
		end

		def add_to_history
			Editor.history << Editor.line
		end

		def exit_script
			exit
		end

		def move_left
			unless Editor.line.bol?:
				print_character BACKSPACE
				Editor.line < 1
			end
		end

		def move_right
			unless Editor.line.eol?:
				Editor.line > 1
				put_character Editor.line.text[Editor.line.position-1]
			end
		end

		def debug_line
			puts 
			puts "Text: [#{Editor.line.text}]"
			puts "Length: #{Editor.line.length}"
			puts "Position: #{Editor.line.position}"
			puts "Character at Position: [#{Editor.line.text[Editor.line.position].chr}] \
		 			(#{Editor.line.text[Editor.line.position]})" unless Editor.line.position >= Editor.line.length
		end

		def delete_left_character
			unless Editor.line.bol?:
				put_character BACKSPACE
				put_character SPACE
				put_character BACKSPACE
				Editor.line < 1
				Editor.line.text.chop!
			end
		end

		def erase_line
			put_character ENTER
			Editor.line.length.times { put_character SPACE }
			put_character ENTER
		end

	
	end
end
