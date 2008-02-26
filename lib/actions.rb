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
			unless Editor.line.length >= Editor.line.max_length-2
				case
				when Editor.line.position < Editor.line.length then
					chars = select_characters_from_cursor
					Editor.line.text[Editor.line.position] = "#{char.chr}#{Editor.line.text[Editor.line.position].chr}"
					put_character char
					Editor.line > 1
					raw_print chars
					chars.length.times { put_character BACKSPACE } # move cursor back
				else
					put_character char
					Editor.line > 1
					unless Editor.char == 224 then
						Editor.line << Editor.char 
					end
				end
				add_to_line_history
			end
		end

		def newline
			add_to_line_history
			add_to_history
		end

		def exit_script
			exit
		end

		def move_left
			unless Editor.line.bol?:
				put_character BACKSPACE
				Editor.line < 1
				return true
			end
			false
		end

		def move_right
			unless Editor.line.position > Editor.line.eol:
				Editor.line > 1
				put_character Editor.line.text[Editor.line.position-1]
				return true
			end
			false
		end

		def debug_line
			pos = Editor.line.position
			text = Editor.line.text
			puts 
			puts "Text: [#{text}]"
			puts "Length: #{Editor.line.length}"
			puts "Position: #{pos}"
			puts "Character at Position: [#{text[pos].chr}] (#{text[pos]})" unless pos >= Editor.line.length
			clear_line
			raw_print text
			Editor.line.text = text
			Editor.line.position = text.length
			move_to_position(pos)
		end

		def debug_history
			line = Editor.line.text
			puts
			puts "History:"
			Editor.history.each {|l| puts "- #{l}"}
			puts "History Position: #{Editor.history.position}"
			overwrite_line(line)
		end

		def clear_history
			Editor.history.clear
		end

		def delete_left_character
			if move_left then
				delete_character
			end
		end

		def delete_character
			unless Editor.line.position > Editor.line.eol
				# save characters to shift
				chars = (Editor.line.eol?) ? ' ' : select_characters_from_cursor(1)
				# remove character from console and shift characters
				raw_print chars
				put_character SPACE
				(chars.length+1).times { put_character BACKSPACE }
				#remove character from line
				Editor.line[Editor.line.position] = ''
				add_to_line_history
			end
		end

		def clear_line
			put_character ENTER
			raw_print Editor.line.prompt
			Editor.line.length.times { put_character SPACE }
			Editor.line.length.times { put_character BACKSPACE }
			Editor.clear_line
			add_to_line_history
		end

		def undo
			generic_history_back(Editor.line.history) if Editor.line.history.position == nil
			generic_history_back(Editor.line.history)
		end

		def repeat
			generic_history_forward(Editor.line.history)
		end

		def history_back
			unless Editor.history.position
				current_line = Editor.line.text.dup
				Editor.history << current_line
				Editor.history.back
			end
			generic_history_back(Editor.history)
		end

		def history_forward
			generic_history_forward(Editor.history)
		end

		def add_to_line_history
			Editor.line.history << Editor.line.text.dup
		end

		def add_to_history
			Editor.history << Editor.line.text.dup
		end

		private

		def generic_history_back(history)
			unless history.empty?
				history.back
				line = history.get
				overwrite_line(line)
			end
		end

		def generic_history_forward(history)
			if history.forward then
				overwrite_line(history.get)
			end
		end

		def overwrite_line(line)
			text = Editor.line.text
			put_character ENTER
			raw_print Editor.line.prompt
			raw_print line
			n = text.length-line.length+1
			if n > 0
				n.times { put_character SPACE } 
				n.times { put_character BACKSPACE }
			end
			Editor.line.text = line
			Editor.line.position = line.length
			move_to_position(line.length)		
		end
		

		def select_characters_from_cursor(offset=0)
			select_characters(:right, Editor.line.length-Editor.line.position, offset)
		end

		def move_to_position(pos)
			n = pos-Editor.line.position
			case
			when n > 0 then
				n.times { move_right }
			when n < 0 then
				n.abs.times {move_left}
			when n == 0 then
			end	
		end

		def select_characters(direction, n, offset=0)
			if direction == :right then
				Editor.line.text[Editor.line.position+offset..Editor.line.position+offset+n]
			elsif direction == :left then
				Editor.line.text[Editor.line.position-offset-n..Editor.line.position-offset]
			end
		end

	end
end
