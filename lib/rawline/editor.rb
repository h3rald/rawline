#!/usr/bin/env ruby

#
#	editor.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module RawLine

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
	# * TAB: word completion defined via completion_proc
	# * LEFT/RIGHT ARROWS: cursor movement (left/right)
	# * UP/DOWN ARROWS: history navigation
	# * DEL: Delete character under cursor
	# * BACKSPACE: Delete character before cursor
	# * INSERT: Toggle insert/replace mode (default: insert)
	# * CTRL+K: Clear the whole line
	# * CTRL+Z: undo (unless already registered by the OS)
	# * CTRL+Y: redo (unless already registered by the OS)
	#
	class Editor

		include HighLine::SystemExtensions

		attr_accessor :char, :history_size, :line_history_size 
		attr_accessor :terminal, :keys, :mode 
		attr_accessor :completion_proc, :line, :history, :completion_append_string 
		attr_accessor :match_hidden_files, :completion_matches
		attr_accessor :word_break_characters

		# 
		# Create an instance of RawLine::Editor which can be used 
		# to read from input and perform line-editing operations.
		# This method takes an optional block used to override the 
		# following instance attributes:
		# * <tt>@history_size</tt> - the size of the editor history buffer (30).
		# * <tt>@line_history_size</tt> - the size of the editor line history buffer (50).
		# * <tt>@keys</tt> - the keys (arrays of character codes) bound to specific actions.
		# * <tt>@word_break_characters</tt> - a string listing all characters which can be used as word separators (" \t\n\"\\'`@$><=;|&{(/").
		# * <tt>@mode</tt> - The editor's character insertion mode (:insert).
		# * <tt>@completion_proc</tt> - a Proc object used to perform word completion.
		# * <tt>@completion_append_string</tt> - a string to append to completed words ('').
		# * <tt>@completion_matches</tt> - word completion candidates.
		# * <tt>@terminal</tt> -  a RawLine::Terminal containing character key codes.
		#
		def initialize(input=STDIN, output=STDOUT)
			@input = input
			@output = output
			case RUBY_PLATFORM
			when /mswin/i then
				@terminal = WindowsTerminal.new
				if RawLine.win32console? then
					@win32_io = Win32::Console::ANSI::IO.new
				end
			else
				@terminal = VT220Terminal.new
			end
			@history_size = 30
			@line_history_size = 50
			@keys = {}
			@word_break_characters = " \t\n\"\\'`@$><=;|&{(/"
			@mode = :insert
			@completion_proc = filename_completion_proc
			@completion_append_string = ''
			@match_hidden_files = false
			@completion_matches = HistoryBuffer.new(0) { |h| h.duplicates = false; h.cycle = true }
			set_default_keys
			yield self if block_given?
			update_word_separator
			@add_history = false 
			@history = HistoryBuffer.new(@history_size) do |h| 
				h.duplicates = false; 
				h.exclude = lambda { |item| item.strip == "" }
			end
			@char = nil
		end

		# 
		# Return the current RawLine version
		#
		def library_version
			"RawLine v#{RawLine.rawline_version}"
		end

		# 
		# Read characters from <tt>@input</tt> until the user presses ENTER 
		# (use it in the same way as you'd use IO#gets)
		# * An optional prompt can be specified to be printed at the beginning of the line ("").
		# * An optional flag can be specified to enable/disable editor history (false)
		#
		def read(prompt="", add_history=false)
			update_word_separator
			@output.print prompt if prompt != ""
			@add_history = add_history
			@line = Line.new(@line_history_size) do |l| 
				l.prompt = prompt
				l.word_separator = @word_separator
			end
			add_to_line_history
			loop do
				read_character
				process_character
				break if @char == @terminal.keys[:enter] || !@char
			end
			@output.print "\n"
			@line.text
		end

		# Readline compatibility aliases
		alias readline read
		alias completion_append_character completion_append_string
		alias completion_append_character= completion_append_string=
		alias basic_word_break_characters word_break_characters
		alias basic_word_break_characters= word_break_characters=
		alias completer_word_break_characters word_break_characters
		alias completer_word_break_characters= word_break_characters=

			# 
			# Read and parse a character from <tt>@input</tt>.
			# This method is called automatically by <tt>read</tt>
			#
			def read_character
				@output.flush
				c = get_character(@input)
				@char = parse_key_code(c) || c
			end

		#
		#	Parse a key or key sequence into the corresponding codes.
		# This method is called automatically by <tt>read_character</tt>
		#
		def parse_key_code(code)
			if @terminal.escape_codes.include? code then
				sequence = [code]
				seqs = []
				loop do
					c = get_character(@input)
					sequence << c
					seqs = @terminal.escape_sequences.select { |e| e[0..sequence.length-1] == sequence }
					break if seqs.empty?
					return sequence if [sequence] == seqs
				end
			else
				return (@terminal.keys.has_value? [code]) ? [code] : nil
			end
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
		#	Write a new line to <tt>@output</tt>, overwriting any existing text
		#	and printing an end of line character.
		#
		def write_line(string)
			clear_line
			@output.print string
			@line.text = string
			add_to_line_history
			add_to_history
			@char = nil
		end

		#
		# Process a character. If the key corresponding to the inputted character
		# is bound to an action, call <tt>press_key</tt>, otherwise call <tt>default_action</tt>.
		# This method is called automatically by <tt>read</tt>
		#
		def process_character
			case @char.class.to_s
			when 'Fixnum' then
				default_action
			when 'Array'
				press_key if key_bound?
			end
		end

		#
		# Bind a key to an action specified via <tt>block</tt>.
		# <tt>key</tt> can be:
		#
		# * A Symbol identifying a character or character sequence defined for the current terminal
		# * A Fixnum identifying a character defined for the current terminal
		# * An Array identifying a character or character sequence defined for the current terminal
		# * A String identifying a character or character sequence, even if it is not defined for the current terminal
		# * An Hash identifying a character or character sequence, even if it is not defined for the current terminal
		# 
		# If <tt>key</tt> is a hash, then:
		#
		# * It must contain only one key/value pair
		# * The key identifies the name of the character or character sequence
		# * The value identifies the code(s) corresponding to the character or character sequence
		# * The value can be a Fixnum, a String or an Array.
		# 
		def bind(key, &block)
			case key.class.to_s
			when 'Symbol' then
				raise BindingException, "Unknown key or key sequence '#{key.to_s}' (#{key.class.to_s})" unless @terminal.keys[key]
				@keys[@terminal.keys[key]] = block
			when 'Array' then
				raise BindingException, "Unknown key or key sequence '#{key.join(", ")}' (#{key.class.to_s})" unless @terminal.keys.has_value? key
				@keys[key] = block
			when 'Fixnum' then
				raise BindingException, "Unknown key or key sequence '#{key.to_s}' (#{key.class.to_s})" unless @terminal.keys.has_value? [key]
				@keys[[key]] = block
			when 'String' then
				if key.length == 1 then
					@keys[[key.ord]] = block
				else
					bind_hash({:"#{key}" => key}, block)
				end
			when 'Hash' then
				raise BindingException, "Cannot bind more than one key or key sequence at once" unless key.values.length == 1
				bind_hash(key, block)
			else
				raise BindingException, "Unable to bind '#{key.to_s}' (#{key.class.to_s})"
			end
			@terminal.update
		end

		# 
		# Return true if the last character read via <tt>read</tt> is bound to an action.
		#
		def key_bound?
			@keys[@char] ? true : false
		end

		# 
		# Call the action bound to the last character read via <tt>read</tt>.
		# This method is called automatically by <tt>process_character</tt>.
		#
		def press_key
			@keys[@char].call
		end

		# 
		# Execute the default action for the last character read via <tt>read</tt>. 
		# By default it prints the character to the screen via <tt>print_character</tt>.
		# This method is called automatically by <tt>process_character</tt>.
		#
		def default_action
			print_character
		end

		#
		# Write a character to <tt>@output</tt> at cursor position, 
		# shifting characters as appropriate.
		# If <tt>no_line_history</tt> is set to <tt>true</tt>, the updated
		# won't be saved in the history of the current line.
		#
		def print_character(char=@char, no_line_history = false)
			unless @line.length >= @line.max_length-2 then
				if @line.position < @line.length then
					chars = select_characters_from_cursor if @mode == :insert
					@output.putc char
					@line.text[@line.position] = (@mode == :insert) ? "#{char.chr}#{@line.text[@line.position].chr}" : "#{char.chr}"
					@line.right
					if @mode == :insert then
						raw_print chars
						chars.length.times { @output.putc ?\b.ord } # move cursor back
					end
				else
					@output.putc char
					@line.right
					@line << char 
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
		# This action is bound to the tab key by default, so the first
		# match is displayed the first time the user presses tab, and all
		# the possible messages will be displayed (cyclically) when tab is
		# pressed again. 
		# 
		def complete
			completion_char = @char
			@completion_matches.empty
			word_start = @line.word[:start]
			sub_word = @line.text[@line.word[:start]..@line.position-1] || ""
			matches  = @completion_proc.call(sub_word) unless !completion_proc || @completion_proc == []
			matches = matches.to_a.compact.sort.reverse
			complete_word = lambda do |match|
				unless @line.word[:text].length == 0
					# If not in a word, print the match, otherwise continue existing word
					move_to_position(@line.word[:end]+@completion_append_string.to_s.length+1)
				end
				(@line.position-word_start).times { delete_left_character(true) }
				write match+@completion_append_string.to_s
			end
			unless matches.empty? then
				@completion_matches.resize(matches.length) 
				matches.each { |w| @completion_matches << w }
				# Get first match
				@completion_matches.back
				match = @completion_matches.get
				complete_word.call(match)
				read_character
				while @char == completion_char do
					move_to_position(word_start)
					@completion_matches.back
					match = @completion_matches.get
					complete_word.call(match)
					read_character
				end
				process_character
			end
		end

		# 
		# Complete file and directory names.
		# Hidden files and directories are matched only if <tt>@match_hidden_files</tt> is true.
		#
		def filename_completion_proc
			lambda do |word|
				dirs = @line.text.split('/')
					path = @line.text.match(/^\/|[a-zA-Z]:\//) ? "/" : Dir.pwd+"/"
				if dirs.length == 0 then # starting directory
					dir = path
				else
					dirs.delete(dirs.last) unless File.directory?(path+dirs.join('/'))
					dir = path+dirs.join('/')
				end
				Dir.entries(dir).select { |e| (e =~ /^\./ && @match_hidden_files && word == '') || (e =~ /^#{word}/ && e !~ /^\./) }
			end
		end


		# 
		# Adds <tt>@line.text</tt> to the editor history. This action is 
		# bound to the enter key by default.
		#
		def newline
			add_to_history
		end

		# 
		# Move the cursor left (if possible) by printing a 
		# backspace, updating <tt>@line.position</tt> accordingly.
		# This action is bound to the left arrow key by default. 
		#
		def move_left
			unless @line.bol? then
				@output.putc ?\b.ord
				@line.left
				return true
			end
			false
		end

		# 
		# Move the cursor right (if possible) by re-printing the
		# character at the right of the cursor, if any, and updating
		# <tt>@line.position</tt> accordingly. 
		# This action is bound to the right arrow key by default.
		#
		def move_right
			unless @line.position > @line.eol then
				@line.right
				@output.putc @line.text[@line.position-1]
				return true
			end
			false
		end

		#
		# Print debug information about the current line. Note that after
		# the message is displayed, the line text and position will be restored.
		#
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

		#
		# Print the content of the editor history. Note that after
		# the message is displayed, the line text and position will be restored.
		#
		def show_history
			pos = @line.position
			text = @line.text
			@output.puts
			@output.puts "History:"
			@history.each {|l| puts "- [#{l}]"}
			overwrite_line(text, pos)
		end

		# 
		# Clear the editor history.
		#
		def clear_history
			@history.empty
		end

		# 
		# Delete the character at the left of the cursor. 
		# If <tt>no_line_hisytory</tt> is set to true, the deletion won't be
		# recorded in the line history.
		# This action is bound to the backspace key by default.
		#
		def delete_left_character(no_line_history=false)
			if move_left then
				delete_character(no_line_history)
			end
		end

		# 
		# Delete the character under the cursor. 
		# If <tt>no_line_hisytory</tt> is set to true, the deletion won't be
		# recorded in the line history.
		# This action is bound to the delete key by default.
		#
		def delete_character(no_line_history=false)
			unless @line.position > @line.eol
				# save characters to shift
				chars = (@line.eol?) ? ' ' : select_characters_from_cursor(1)
				# remove character from console and shift characters
				raw_print chars
				@output.putc ?\s.ord
				(chars.length+1).times { @output.putc ?\b.ord }
				#remove character from line
				@line[@line.position] = ''
				add_to_line_history unless no_line_history
			end
		end

		# 
		# Clear the current line, i.e. 
		# <tt>@line.text</tt> and <tt>@line.position</tt>.
		# This action is bound to ctrl+k by default.
		#
		def clear_line
			@output.putc ?\r
			print @line.prompt
			@line.length.times { @output.putc ?\s.ord }
			@line.length.times { @output.putc ?\b.ord }
			add_to_line_history
			@line.text = ""
			@line.position = 0
		end

		# 
		# Undo the last modification to the current line (<tt>@line.text</tt>).
		# This action is bound to ctrl+z by default.
		#
		def undo
			generic_history_back(@line.history) if @line.history.position == nil
			generic_history_back(@line.history)
		end

		# 
		# Redo a previously-undone modification to the 
		# current line (<tt>@line.text</tt>).
		# This action is bound to ctrl+y by default.
		#
		def redo
			generic_history_forward(@line.history)
		end

		# 
		# Load the previous entry of the editor in place of the 
		# current line (<tt>@line.text</tt>).
		# This action is bound to the up arrow key by default.
		#
		def history_back
			unless @history.position
				current_line = @line.text.dup
				# Temporarily override exclusion rules
				exclude = @history.exclude.dup
				@history.exclude = lambda{|a|}
				# Add current line
				@history << current_line
				@history.exclude = exclude
				@history.back
			end
			generic_history_back(@history)
			add_to_line_history
		end

		# 
		# Load the next entry of the editor history in place of the 
		# current line (<tt>@line.text</tt>).
		# This action is bound to down arrow key by default.
		#
		def history_forward
			generic_history_forward(@history)
			add_to_line_history
		end

		# 
		# Add the current line (<tt>@line.text</tt>) to the 
		# line history, to allow undo/redo 
		# operations.
		#
		def add_to_line_history
			@line.history << @line.text.dup unless @line.text == ""
		end

		#
		# Add the current line (<tt>@line.text</tt>) to the editor history.
		#
		def add_to_history
			@history << @line.text.dup if @add_history && @line.text != ""
		end

		# 
		# Toggle the editor <tt>@mode</tt> to :replace or :insert (default).
		#
		def toggle_mode
			case @mode
			when :insert then @mode = :replace
			when :replace then @mode = :insert
			end
		end

		#
		# Overwrite the current line (<tt>@line.text</tt>) 
		# with <tt>new_line</tt>, and optionally reset the cursor position to
		# <tt>position</tt>.
		#
		def overwrite_line(new_line, position=nil)
			pos = position || new_line.length
			text = @line.text
			@output.putc ?\r.ord
			print @line.prompt
			raw_print new_line
			n = text.length-new_line.length+1
			if n > 0
				n.times { @output.putc ?\s.ord } 
				n.times { @output.putc ?\b.ord }
			end
			@line.position = new_line.length
			move_to_position(pos)		
			@line.text = new_line
		end

		# 
		# Move the cursor to <tt>pos</tt>.
		#
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

		def update_word_separator
			return @word_separator = "" if @word_break_characters.to_s == ""
			chars = []
			@word_break_characters.each_byte do |c|
				ch = (c.is_a? Fixnum) ? c : c.ord
				value = (ch == ?\s.ord) ? ' ' : Regexp.escape(ch.chr).to_s
				chars << value
			end
			@word_separator = /#{chars.join('|')}/
		end

		def bind_hash(key, block)
			key.each_pair do |j,k|
				raise BindingException, "'#{k[0].chr}' is not a legal escape code for '#{@terminal.class.to_s}'." unless k.length > 1 && @terminal.escape_codes.include?(k[0].ord)
				code = []
				case k.class.to_s
				when 'Fixnum' then
					code = [k]
				when 'String' then
					k.each_byte { |b| code << b }
				when 'Array' then
					code = k
				else
					raise BindingException, "Unable to bind '#{k.to_s}' (#{k.class.to_s})"
				end
				@terminal.keys[j] = code
				@keys[code] = block
			end
		end

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
			bind(:enter) { newline }
			bind(:tab) { complete }
			bind(:backspace) { delete_left_character }
			bind(:ctrl_k) { clear_line }
			bind(:ctrl_u) { undo }
			bind(:ctrl_r) { self.redo }
			bind(:left_arrow) { move_left }
			bind(:right_arrow) { move_right }
			bind(:up_arrow) { history_back }
			bind(:down_arrow) { history_forward }
			bind(:delete) { delete_character }
			bind(:insert) { toggle_mode }
		end

	end

	if RawLine.ansi? then

		class Editor

			if RUBY_PLATFORM.match(/mswin/) && RawLine.win32console? then
				def escape(string)
					string.each_byte { |c| @win32_io.putc c }
				end
			else
				def escape(string)
					@output.print string
				end
			end

			undef move_left
			def move_left
				unless @line.bol? then
					@line.left
					escape "\e[D"
					return true
				end
				false
			end

			undef move_right
			def move_right
				unless @line.position > @line.eol then
					@line.right
					escape "\e[C"
					return true
				end
				false
			end

		end
	end

end


