#!/usr/bin/ruby

module InLine
	HOME = File.dirname(File.expand_path(__FILE__))
end

require "highline"
require "#{InLine::HOME}/mappings"
require "#{InLine::HOME}/history_buffer"
require "#{InLine::HOME}/line"
require "#{InLine::HOME}/editor"


