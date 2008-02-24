#!/usr/bin/ruby

module Inline
	HOME = File.dirname(File.expand_path(__FILE__))

	MAX_UNDO_OPERATIONS = 3
	MAX_HISTORY_ITEMS = 5
end

require "highline"
require "#{Inline::HOME}/system_extensions"
require "#{Inline::HOME}/mappings"
require "#{Inline::HOME}/actions"
require "#{Inline::HOME}/keyboard"
require "#{Inline::HOME}/history_buffer"
require "#{Inline::HOME}/line"
require "#{Inline::HOME}/editor"


