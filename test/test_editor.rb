#!/usr/local/bin/ruby -w

module InLine
	TEST_HOME = File.dirname(File.expand_path(__FILE__))+'/..' unless const_defined?(:TEST_HOME)
end

require 'highline/system_extensions'

module HighLine::SystemExtensions
  # Override Windows' character reading so it's not tied to STDIN.
  def get_character( input = STDIN )
		input.getc
  end
end

require 'stringio'
require "#{InLine::TEST_HOME}/lib/inline"

describe InLine::Editor do

	before :each do
		@output = StringIO.new
		@input = StringIO.new
		@editor = InLine::Editor.new(@input, @output)
	end

	it "reads raw characters from @input" do
		@input << "test #1"
		@input.rewind
	 	@editor.read
		@editor.line.text.should == "test #1"
		@output.string.should == "test #1"
	end

	it "can bind keys to code blocks" do
		@editor.bind(:ctrl_w) { @editor.write "test #2a" }
		@editor.bind(?\C-q) { "test #2b" }
		@editor.bind(21) { "test #2c" }
		@editor.bind([22]) { "test #2d" }
		@editor.terminal.escape_codes = [] # remove any existing escape codes
		lambda {@editor.bind({:test => [?\e, ?t, ?e, ?s, ?t]}) { "test #2e" }}.should raise_error(InLine::BindingException)
		@editor.terminal.escape_codes << ?\e
		lambda {@editor.bind({:test => "\etest"}) { "test #2e" }}.should_not raise_error(InLine::BindingException)
		lambda {@editor.bind("\etest2") { "test #2f" }}.should_not raise_error(InLine::BindingException)
		@input << ?\C-w.chr
		@input.rewind
	 	@editor.read
		@editor.line.text.should == "test #2a"
		@editor.char = [?\C-q]
		@editor.press_key.should == "test #2b"
		@editor.char = [?\C-u]
		@editor.press_key.should == "test #2c"
		@editor.char = [?\C-v]
		@editor.press_key.should == "test #2d"
		@editor.char = [?\e, ?t, ?e, ?s, ?t]
		@editor.press_key.should == "test #2e"
		@editor.char = [?\e, ?t, ?e, ?s, ?t, ?2]
		@editor.press_key.should == "test #2f"
	end

	it "keeps track of the cursor position" do
		@input << "test #4"
		@input.rewind
		@editor.read
		@editor.line.position.should == 7
		3.times { @editor.move_left }
		@editor.line.position.should == 4
		2.times { @editor.move_right }
		@editor.line.position.should == 6
	end

	it "can delete characters" do
		@input << "test #5"
		@input.rewind
		@editor.read
		3.times { @editor.move_left }
		4.times { @editor.delete_left_character }
		3.times { @editor.delete_character }
		@editor.line.text.should == ""
		@editor.line.position.should == 0
	end

	it "can clear the whole line" do
		@input << "test #5"
		@input.rewind
		@editor.read
		@editor.clear_line
		@editor.line.text.should == ""
		@editor.line.position.should == 0
	end

	it "supports undo and redo" do
		@input << "test #6"
		@input.rewind
		@editor.read
		3.times { @editor.delete_left_character }
		2.times { @editor.undo }
		@editor.line.text.should == "test #"
		2.times { @editor.redo }
		@editor.line.text.should == "test"
	end

	it "supports history" do
		@input << "test #7a"
		@input.rewind
		@editor.read
		@editor.newline
		@input << "test #7b"
		@input.pos = 8
		@editor.read
		@editor.newline
		@input << "test #7c"
		@input.pos = 16
		@editor.read
		@editor.newline
		@input << "test #7d"
		@input.pos = 24
		@editor.read
		@editor.newline
		@editor.history_back
		@editor.line.text.should == "test #7c"
		10.times { @editor.history_back }
		@editor.line.text.should == "test #7a"
		2.times { @editor.history_forward }
		@editor.line.text.should == "test #7c"
	end

	it "can overwrite lines" do
		@input << "test #8a"
		@input.rewind
		@editor.read
		@editor.overwrite_line("test #8b", 2)
		@editor.line.text.should == "test #8b"
		@editor.line.position.should == 2
	end

	it "can complete words" do
		@editor.completion_append_string = "\t"
		@editor.bind(:tab) { @editor.complete }
		@editor.completion_proc = lambda do |word|
	  	if word
 				['select', 'update', 'delete', 'debug', 'destroy'].find_all	{ |e| e.match(/^#{Regexp.escape(word)}/) }
			end
		end
		@input << "test #9 de" << ?\t.chr << ?\t.chr
		@input.rewind
		@editor.read
		@editor.line.text.should == "test #9 delete\t"
	end

	it "supports INSERT and REPLACE modes" do
		@input << "test 0" 
		@editor.terminal.keys[:left_arrow].each { |k| @input << k.chr }
		@input << "#1"
		@input.rewind
		@editor.read
		@editor.line.text.should == "test #10"
		@editor.toggle_mode
		@input << "test 0" 
		@editor.terminal.keys[:left_arrow].each { |k| @input << k.chr }
		@input << "#1"
		@input.pos = 10
		@editor.read
		@editor.line.text.should == "test #1"
	end
	

end

