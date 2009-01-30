#!/usr/local/bin/ruby -w

module RawLine
	TEST_HOME = File.dirname(File.expand_path(__FILE__))+'/..' unless const_defined?(:TEST_HOME)
end

require "history_buffer_spec"
require "line_spec"
require "editor_spec"
