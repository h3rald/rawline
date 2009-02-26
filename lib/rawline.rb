#!/usr/local/bin/ruby -w

#
#	RawLine.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module RawLine
	HOME = File.dirname(File.expand_path(__FILE__))
	class BindingException < Exception; end
	begin
		if RUBY_PLATFORM.match(/mswin/i)
			WIN32CONSOLE = require "win32console" 
		else
			WIN32CONSOLE = false
		end
		ANSI = true
	rescue
		ANSI = false
	end
end

require "rubygems"
require "highline"
require "#{RawLine::HOME}/rawline/terminal"
require "#{RawLine::HOME}/rawline/terminal/windows_terminal"
require "#{RawLine::HOME}/rawline/terminal/vt220_terminal"
require "#{RawLine::HOME}/rawline/history_buffer"
require "#{RawLine::HOME}/rawline/line"
require "#{RawLine::HOME}/rawline/editor"
