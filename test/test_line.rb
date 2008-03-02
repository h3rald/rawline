#!/usr/bin/env ruby

module InLine
	TEST_HOME = File.dirname(File.expand_path(__FILE__))+'/..' unless const_defined?(:TEST_HOME)
end

require 'highline'

require "#{InLine::TEST_HOME}/lib/history_buffer"
require "#{InLine::TEST_HOME}/lib/line"

describe InLine::Line do

	before :each do
		@line = InLine::Line.new(5) {|l| l.prompt = "=>" }
	end

	it "allows characters to be added to @text via the '<<' operator" do
		@line.text = "test #1"
		@line << 'a'[0]
		@line.text.should == "test #1a"
	end

	it "allows characters to be retrieved and substituted via '[]' and '[]=' operators" do
		@line.text = 'test #2'
		@line[0] = 't'
		@line[0..3].should == 'test'
		@line[4..6] = ''
		@line[0] = "This is a t"
		@line.text.should == "This is a test"
	end

	it "updates @position via '<' and '>'" do
		@line.text = "test #3"
		@line > 2
		@line.position.should == 2
		@line < 1
		@line.position.should == 1
		@line < 4
		@line.position.should == 0
		@line > 210
		@line.position.should == 118 # Default terminal_size()[0]
		@line.eol.should == 6
	end

	it "is aware of the word in which the cursor is" do
		@line.text = "This is another test"
		@line.word.should == {:start => 0, :end => 3, :text => "This"}
		@line > 2
		@line[2].should == 'i'[0]
		@line.word.should == {:start => 0, :end => 3, :text => "This"}
		@line > 1
		@line.word.should == {:start => 0, :end => 3, :text => "This"}
		@line > 1
		@line.word.should == {:start => 0, :end => 3, :text => "This"}
		@line > 1
		@line.word.should == {:start => 5, :end => 6, :text => "is"}
	end

end
