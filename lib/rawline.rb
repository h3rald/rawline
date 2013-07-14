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
module RawLine

	def self.rawline_version
		"0.3.2"
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
		class << self;	attr_accessor :editor end
		@editor = RawLine::Editor.new

		@implemented_methods = 
			[
				:completion_proc,
				:completion_proc=,
				:completion_matches,
				:completion_append_character,
				:completion_append_character=,
				:basic_word_break_characters,
				:basic_word_break_characters=,
				:completer_word_break_characters,
				:completer_word_break_characters=,
				:library_version,
				:clear_history,
				:match_hidden_files,
				:match_hidden_files=
			]

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
		
		private
		
		HISTORY = RawLine.editor.history
		FILENAME_COMPLETION_PROC = RawLine.editor.filename_completion_proc

		readline_method = lambda do

			def readline(prompt="", add_history=false)
				RawLine.editor.read prompt, add_history
			end

			alias rawline readline
		end
		
		self.class.module_eval { readline_method.call }
		self.module_eval { readline_method.call }

	end
end
