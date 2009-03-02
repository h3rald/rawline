#!usr/bin/env ruby

#
#	RawLine.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

require "rubygems"

#
# The RawLine (or Rawline) module can be used in the same way
# as the Readline one.
#
#	<tt>require 'rawline'</tt>
#	<tt>include Rawline</tt>
#	
#	You'll get...
#
#	* <tt>readline(prompt="", add_history=false)</tt> - to read characters from $stdin
#	* <tt>Rawline::HISTORY</tt> - to access line history (an instance of RawLine::HistoryBuffer)
#	* <tt>Rawline::FILENAME_COMPLETION_PROC</tt> -  a Proc object used for filename completion
#	* <tt>Rawline.completion_proc</tt> - the Proc object used for TAB completion (defaults to FILENAME_COMPLETION_PROC).
#	* <tt>Rawline.completion_matches</tt> - an array of completion matches.
#	* <tt>Rawline.completion_append_char</tt> - a character to append after a successful completion.
#	* <tt>Rawline.basic_word_break_characters</tt> - a String listing all the characters used as word separators.
#	* <tt>Rawline.completer_word_break_characters</tt> - same as above. 
#	* <tt>Rawline.library_version</tt> - the current version of the Rawline library.
#	* <tt>Rawline.clear_history</tt> - to clear the current history.
#	* <tt>Rawline.match_hidden_files</tt> - whether FILENAME_COMPLETION_PROC matches hidden files and folders or not.
#
#	And also <tt>Rawline.editor</tt>, an instance of RawLine::Editor which can be used for anything you like.
#
module RawLine

	def self.rawline_version
		"0.3.0"
	end

	class BindingException < RuntimeError; end

	if RUBY_PLATFORM.match(/mswin/i) then
		begin
			require 'win32console'
			def self.win32console?; true; end
			def self.ansi?; true; end
		rescue Exception
			def self.win32console?; false; end
			def self.ansi?; false; end
		end
	else # Unix-like
		def self.ansi?; true; end
	end
end

# Adding Fixnum#ord for Ruby 1.8.6
class Fixnum;	def ord; self; end;	end unless Fixnum.method_defined? :ord

Rawline = RawLine

dir = File.dirname(File.expand_path(__FILE__))
require "highline"
require "#{dir}/rawline/terminal"
require "#{dir}/rawline/terminal/windows_terminal"
require "#{dir}/rawline/terminal/vt220_terminal"
require "#{dir}/rawline/history_buffer"
require "#{dir}/rawline/line"
require "#{dir}/rawline/editor"

module RawLine
	self.instance_eval do
		class << self;	attr_accessor :editor, :implemented_methods;	end
		@editor = RawLine::Editor.new

		@implemented_methods = 
			[
				:completion_proc,
				:completion_proc=,
				:completion_matches,
				:completion_append_char,
				:completion_append_char=,
				:basic_word_break_characters,
				:basic_word_break_characters=,
				:completer_word_break_characters,
				:completer_word_break_characters=,
				:library_version,
				:clear_history,
				:match_hidden_files,
				:match_hidden_files=
			]

		self.module_eval do
			HISTORY = RawLine.editor.history
			FILENAME_COMPLETION_PROC = RawLine.editor.filename_completion_proc

			def readline(prompt="", add_history=false)
				RawLine.editor.read prompt, add_history
			end

			alias rawline readline
		end

		@implemented_methods.each do |meth|				
			self.class.module_eval do
				define_method meth do |*args|
					case args.length
					when 0 then
						@editor.send(meth)
					when 1 then
						@editor.send(meth, args[0])
					else
						raise ArgumentError, "There are no Readline methods with more than one parameter"						
					end
				end
			end
		end

	end

end
