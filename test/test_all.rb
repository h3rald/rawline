#!/usr/local/bin/ruby -w

module RawLine
	TEST_HOME = File.dirname(File.expand_path(__FILE__))+'/..' unless const_defined?(:TEST_HOME)
end

require "test_history_buffer"
require "test_line"
require "test_editor"
