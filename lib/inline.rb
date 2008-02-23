#!/usr/bin/ruby

module Inline
	HOME = File.dirname(File.expand_path(__FILE__))
end

require "highline"
require "#{Inline::HOME}/system_extensions"
require "#{Inline::HOME}/mappings"
require "#{Inline::HOME}/actions"
require "#{Inline::HOME}/keyboard"
require "#{Inline::HOME}/line"
require "#{Inline::HOME}/editor"


