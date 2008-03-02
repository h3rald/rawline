#!/usr/bin/ruby

module InLine
	HOME = File.dirname(File.expand_path(__FILE__))
end

require "highline"
require "#{InLine::HOME}/inline/mappings"
require "#{InLine::HOME}/inline/history_buffer"
require "#{InLine::HOME}/inline/line"
require "#{InLine::HOME}/inline/editor"


