#!/usr/bin/ruby

module InLine

	class Editor

		include HighLine::SystemExtensions
		include Mappings

		attr_accessor :history_size, :line_history_size, :keys, :word_separator, :mode, :completion_proc

		def initialize
			@history_size = 30
			@line_history_size = 50
			@keys = []
			@word_separator = ' '
			@mode = :insert
			@completion_proc = []
			@completion_matches = HistoryBuffer.new(0) { |h| h.duplicates = false; h.cycle = true }
			set_default_keys
			yield self if block_given?
			@history = InLine::HistoryBuffer.new(@history_size) do |h| 
				h.duplicates = false; 
				h.exclude = lambda { |item| item.strip == "" }
			end
			@char = nil
			@newline = true
		end

		def read(prompt="", input=STDIN)
			@input = input
			@newline = true
			@line = Line.new(@line_history_size) do |l| 
				l.prompt = prompt
				l.word_separator = @word_separator
			end
			add_to_line_history
			loop do
				print prompt if @newline
				@newline = false
				@char = get_character(@input)
				process_character
				break if @char == ENTER
			end
			puts
			@line
		end

		def process_character
			if key_bound?: press_key
			else default_action
			end
		end

		def bind(key, &block)
			@keys[key] = block
		end

		def key_bound?
			@keys[@char] ? true : false
		end

		def key_mapped?
			Mappings.constants.each do |c| 
				return true if (Mappings.const_get(:"#{c}") == ("#{@char}"))
			end
			false
		end

		def press_key
			@keys[@char].call
		end

		### ACTIONS ###

		def default_action
			unless key_mapped?
				print_character
			end
		end

		def write(string)
			string.each_byte { |c| print_character c }
		end

		def print_character(char=@char)
			unless @line.length >= @line.max_length-2
				case
				when @line.position < @line.length then
					chars = select_characters_from_cursor if @mode == :insert
					putc char
					@line.text[@line.position] = (@mode == :insert) ? "#{char.chr}#{@line.text[@line.position].chr}" : "#{char.chr}"
					@line > 1
					if @mode == :insert then
						raw_print chars
						chars.length.times { putc BACKSPACE } # move cursor back
					end
				else
					putc char
					@line > 1
					unless char == SPECIAL then
						@line << char 
					end
				end
				add_to_line_history unless char != @char
			end
		end

		def complete
			completion_char = @char
			pos = @line.position
			@completion_matches.clear
			sub_word = @line.text[@line.word[:start]..@line.position-1] || ""
			matches  = @completion_proc.call(sub_word)
			matches = (matches.is_a?(Array)) ? matches.sort.reverse : []
			unless matches.empty? then
				@completion_matches.resize(matches.length) 
				matches.each { |w| @completion_matches << w }
				# Get first match
				@completion_matches.back
				match = @completion_matches.get
				complete_word(match)
				@char = get_character(@input)
				while @char == completion_char do
					move_to_position(pos)
					@completion_matches.back
					match = @completion_matches.get
					complete_word(match)
					@char = get_character(@input)
				end
				process_character
			end
		end

		def newline
			add_to_history
		end

		def exit_script
			exit
		end

		def move_left
			unless @line.bol?:
				putc BACKSPACE
				@line < 1
				return true
			end
			false
		end

		def move_right
			unless @line.position > @line.eol:
				@line > 1
				putc @line.text[@line.position-1]
				return true
			end
			false
		end

		def debug_line
			pos = @line.position
			text = @line.text
			word = @line.word
			puts 
			puts "Text: [#{text}]"
			puts "Length: #{@line.length}"
			puts "Position: #{pos}"
			puts "Character at Position: [#{text[pos].chr}] (#{text[pos]})" unless pos >= @line.length
			puts "Current Word: [#{word[:text]}] (#{word[:start]} -- #{word[:end]})"
			clear_line
			raw_print text
			overwrite_line(text, pos)
		end

		def show_history
			pos = @line.position
			text = @line.text
			puts
			puts "History:"
			@history.each {|l| puts "- [#{l}]"}
			overwrite_line(text, pos)
		end

		def clear_history
			@history.clear
		end

		def delete_left_character
			if move_left then
				delete_character
			end
		end

		def delete_character
			unless @line.position > @line.eol
				# save characters to shift
				chars = (@line.eol?) ? ' ' : select_characters_from_cursor(1)
				# remove character from console and shift characters
				raw_print chars
				putc SPACE
				(chars.length+1).times { putc BACKSPACE }
				#remove character from line
				@line[@line.position] = ''
				add_to_line_history
			end
		end

		def clear_line
			putc ENTER
			raw_print @line.prompt
			@line.length.times { putc SPACE }
			@line.length.times { putc BACKSPACE }
			@clear_line
			add_to_line_history
		end

		def undo
			generic_history_back(@line.history) if @line.history.position == nil
			generic_history_back(@line.history)
		end

		def repeat
			generic_history_forward(@line.history)
		end

		def history_back
			unless @history.position
				current_line = @line.text.dup
				# Temporarily override exclusion rules
				exclude = @history.exclude.dup
				@history.exclude = lambda { nil }
				# Add current line
				@history << current_line
				@history.exclude = exclude
				@history.back
			end
			generic_history_back(@history)
			add_to_line_history
		end

		def history_forward
			generic_history_forward(@history)
			add_to_line_history
		end

		def add_to_line_history
			@line.history << @line.text.dup unless @line.text == ""
		end

		def add_to_history
			@history << @line.text.dup unless @line.text == ""
		end

		def toggle_mode
			case @mode
			when :insert then @mode = :replace
			when :replace then @mode = :insert
			end
		end

		def overwrite_line(new_line, position=nil)
			pos = position || new_line.length
			text = @line.text
			putc ENTER
			raw_print @line.prompt
			raw_print new_line
			n = text.length-new_line.length+1
			if n > 0
				n.times { putc SPACE } 
				n.times { putc BACKSPACE }
			end
			@line.position = new_line.length
			move_to_position(pos)		
			@line.text = new_line
		end

		def select_characters_from_cursor(offset=0)
			select_characters(:right, @line.length-@line.position, offset)
		end

		def move_to_position(pos)
			n = pos-@line.position
			case
			when n > 0 then
				n.times { move_right }
			when n < 0 then
				n.abs.times {move_left}
			when n == 0 then
			end	
		end

		private

		def raw_print(string)
			string.each_byte { |c| putc c }
		end

		def complete_word(match)
			if @line.word[:text].length == 0 then
				# If not in a word, print the match
				match.each_byte {|c| print_character c }
			else
				# Otherwise continue existing word
				move_to_position(@line.word[:end]+1)
				@line.word[:text].length.times { delete_left_character }
				# Substitute word with match
				match.each_byte {|c| print_character c }
			end
		end

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

		def select_characters(direction, n, offset=0)
			if direction == :right then
				@line.text[@line.position+offset..@line.position+offset+n]
			elsif direction == :left then
				@line.text[@line.position-offset-n..@line.position-offset]
			end
		end

		def set_default_keys		
			bind(ENTER) { newline }
			bind(TAB) { complete }
			bind(CTRL_X) { exit_script }
			bind(BACKSPACE) { delete_left_character }
			bind(CTRL_K) { clear_line }
			bind(CTRL_Z) { undo }
			bind(CTRL_Y) { repeat }
			bind(SPECIAL) do
				arrow_char = get_character(@input)
				case arrow_char
				when LEFT_ARROW: move_left
				when RIGHT_ARROW: move_right
				when UP_ARROW: history_back
				when DOWN_ARROW: history_forward
				when DEL: delete_character
				when INSERT: toggle_mode 
				else nil
				end
			end
		end

	end
end


