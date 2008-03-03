#!/usr/local/bin/ruby -w

#
#	editor.rb
#
# Created by Fabio Cevasco on 2008-03-03.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module InLine

	# 
	# The Editor class defines methods to:
	#
	# * Read characters from STDIN or any type of input
	# * Write characters to STDOUT or any type of output
	# * Bind keys to specific actions
	# * Perform line-related operations like moving, navigating through history, etc.
	# 
	# Note that the following default key bindings are provided:
	#
	# * TAB: word completion defined via completion_proc()
	# * LEFT/RIGHT ARROWS: cursor movement (left/right)
	# * UP/DOWN ARROWS: history navigation
	# * DEL: Delete character under cursor
	# * BACKSPACE: Delete character before cursor
	# * INSERT: Toggle insert/replace mode (default: insert)
	# * CTRL+K: Clear the whole line
	# * CTRL+Z: undo
	# * CTRL+Y: redo
	#
	class Editor

		include HighLine::SystemExtensions
		include Mappings

		attr_accessor :history_size, :line_history_size, :keys, :word_separator, :mode, :completion_proc, :line, :history, :completion_append_character

		# 
		# Create an instance of InLine::Editor which can be used 
		# to read from input and perform line-editing operations.
		# It takes an optional block used to override the following instance attributes:
		# * <tt>@history_size</tt>
		# * <tt>@line_history_size</tt>
		# * <tt>@keys</tt>
		# * <tt>@word_separator</tt>
		# * <tt>@mode</tt>
		# * <tt>@completion_proc</tt>
		# * <tt>@completion_append_character</tt>
		# * <tt>@completion_matches</tt>
		#
		def initialize(input=STDIN, output=STDOUT)
			@input = input
			@output = output
			@history_size = 30
			@line_history_size = 50
			@keys = []
			@word_separator = ' '
			@mode = :insert
			@completion_proc = []
			@completion_append_character = " "
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
		
		# 
		# Read characters from <tt>@input</tt> until the user presses ENTER 
		# (use it in the same way as you'd use IO#gets)
		# An optional prompt can be specified to be printed at the beginning of the line.
		#
		def read(prompt="")
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
				break if @char == ENTER || !@char
			end
			puts
			@line.text
		end

		# 
		# Write a string to <tt>@output</tt> starting from the cursor position. 
		# Characters at the right of the cursor are shifted to the right if 
		# <tt>@mode == :insert</tt>, deleted otherwise.
		#
		def write(string)
			string.each_byte { |c| print_character c, true }
			add_to_line_history
		end

		#
		# Process a character. If the key corresponding to the inputted character
		# is bound to an action, call <tt>press_key</tt>, otherwise call <tt>default_action</tt>.
		# This method is called automatically by <tt>read()</tt>
		#
		def process_character
			unless !@char
				if key_bound?: press_key
				else default_action
				end
			end
		end

		#
		# Bind a key (identified via its ASCII code) to an action specified via <tt>block</tt>.
		#
		def bind(key, &block)
			@keys[key] = block
		end

		# 
		# Return true if the last character read via <tt>read()</tt> is bound to an action.
		#
		def key_bound?
			@keys[@char] ? true : false
		end

		# 
		# Return true if the last character read via <tt>read()</tt> is mapped in InLine::Mappings.
		#
		def key_mapped?
			Mappings.constants.each do |c| 
				return true if (Mappings.const_get(:"#{c}") == ("#{@char}"))
			end
			false
		end

		# 
		# Call the action bound to the last character read via <tt>read()</tt>.
		# This method is called automatically by <tt>process_character()</tt>.
		#
		def press_key
			@keys[@char].call
		end

		# 
		# Execute the default action for the last character read via <tt>read()</tt>. 
		# By default it prints the character to the screen via <tt>print_character()</tt> if is not mapped.
		# This method is called automatically by <tt>process_character()</tt>.
		#
		def default_action
			unless key_mapped?
				print_character
			end
		end

		#
		# Write a character to <tt>@output</tt> at cursor position, 
		# shifting characters as appropriate.
		# If <tt>no_line_history</tt> is set to <tt>true</tt>, the updated
		# won't be saved in the history of the current line.
		#
		def print_character(char=@char, no_line_history = false)
			unless @line.length >= @line.max_length-2
				case
				when @line.position < @line.length then
					chars = select_characters_from_cursor if @mode == :insert
					@output.putc char
					@line.text[@line.position] = (@mode == :insert) ? "#{char.chr}#{@line.text[@line.position].chr}" : "#{char.chr}"
					@line > 1
					if @mode == :insert then
						raw_print chars
						chars.length.times { putc BACKSPACE } # move cursor back
					end
				else
					@output.putc char
					@line > 1
					unless char == SPECIAL then
						@line << char 
					end
				end
				add_to_line_history unless no_line_history
			end
		end
		
		# 
		# Complete the current word according to what returned by
		# <tt>@completion_proc</tt>. Characters can be appended to the 
		# completed word via <tt>@completion_append_character</tt> and word
		# separators can be defined via <tt>@word_separator</tt>.
		#
		# This action is bound to TAB by default, so the first
		# match is displayed the first time the user presses TAB, and all
		# the possible messages will be displayed (cyclically) when TAB is
		# pressed again. 
		# 
		def complete
			completion_char = @char
			@completion_matches.clear
			word_start = @line.word[:start]
			sub_word = @line.text[@line.word[:start]..@line.position-1] || ""
			matches  = @completion_proc.call(sub_word)
			matches = (matches.is_a?(Array)) ? matches.sort.reverse : []
			complete_word = lambda do |match|
				unless @line.word[:text].length == 0
					# If not in a word, print the match, otherwise continue existing word
					move_to_position(@line.word[:end]+@completion_append_character.length+1)
				end
				(@line.position-word_start).times { delete_left_character(true) }
				write match+@completion_append_character
			end
			unless matches.empty? then
				@completion_matches.resize(matches.length) 
				matches.each { |w| @completion_matches << w }
				# Get first match
				@completion_matches.back
				match = @completion_matches.get
				complete_word.call(match)
				@char = get_character(@input)
				while @char == completion_char do
					move_to_position(word_start)
					@completion_matches.back
					match = @completion_matches.get
					complete_word.call(match)
					@char = get_character(@input)
				end
				process_character
			end
		end

		# 
		# Adds the current line to the editor history. This action is 
		# bound to the ENTER key by default.
		#
		def newline
			add_to_history
		end

		#
		# Quit the script calling <tt>Kernel#exit</tt>.
		#
		def quit
			exit
		end

		# 
		# Move the cursor left (if possible) by printing a 
		# BACKSPACE, updating <tt>@line.position</tt> accordingly.
		# This action is bound to LEFT_ARROW by default. 
		#
		def move_left
			unless @line.bol?:
				@output.putc BACKSPACE
				@line < 1
				return true
			end
			false
		end
		
		# 
		# Move the cursor right (if possible) by re-printing the
		# character at the right of the cursor, if any, and updating
		# <tt>@line.position</tt> accordingly. 
		# This action is bound to RIGHT_ARROW by default.
		#
		def move_right
			unless @line.position > @line.eol:
				@line > 1
				@output.putc @line.text[@line.position-1]
				return true
			end
			false
		end

		def debug_line
			pos = @line.position
			text = @line.text
			word = @line.word
			@output.puts 
			@output.puts "Text: [#{text}]"
			@output.puts "Length: #{@line.length}"
			@output.puts "Position: #{pos}"
			@output.puts "Character at Position: [#{text[pos].chr}] (#{text[pos]})" unless pos >= @line.length
			@output.puts "Current Word: [#{word[:text]}] (#{word[:start]} -- #{word[:end]})"
			clear_line
			raw_print text
			overwrite_line(text, pos)
		end

		def show_history
			pos = @line.position
			text = @line.text
			@output.puts
			@output.puts "History:"
			@history.each {|l| puts "- [#{l}]"}
			overwrite_line(text, pos)
		end

		def clear_history
			@history.clear
		end

		def delete_left_character(no_line_history=false)
			if move_left then
				delete_character(no_line_history)
			end
		end

		def delete_character(no_line_history=false)
			unless @line.position > @line.eol
				# save characters to shift
				chars = (@line.eol?) ? ' ' : select_characters_from_cursor(1)
				# remove character from console and shift characters
				raw_print chars
				putc SPACE
				(chars.length+1).times { putc BACKSPACE }
				#remove character from line
				@line[@line.position] = ''
				add_to_line_history unless no_line_history
			end
		end

		def clear_line
			@output.putc ENTER
			raw_print @line.prompt
			@line.length.times { putc SPACE }
			@line.length.times { putc BACKSPACE }
			add_to_line_history
			@line.text = ""
			@line.position = 0
		end

		def undo
			generic_history_back(@line.history) if @line.history.position == nil
			generic_history_back(@line.history)
		end

		def redo
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

		def select_characters_from_cursor(offset=0)
			select_characters(:right, @line.length-@line.position, offset)
		end

		def raw_print(string)
			string.each_byte { |c| @output.putc c }
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
			bind(BACKSPACE) { delete_left_character }
			bind(CTRL_K) { clear_line }
			bind(CTRL_Z) { undo }
			bind(CTRL_Y) { self.redo }
			bind(SPECIAL) do
				special_char = get_character(@input)
				case special_char
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


