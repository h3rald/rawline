#!/usr/bin/env ruby

require 'highline/system_extensions'

module HighLine::SystemExtensions
  # Override Windows' character reading so it's not tied to STDIN.
  def get_character( input = STDIN )
		(RUBY_VERSION.gsub(/1\./, '').to_f >= 8.7) ? input.getbyte : input.getc
  end
end

require 'stringio'
require_relative "../lib/rawline.rb"

describe RawLine::Editor do

	before :each do
		@output = StringIO.new
		@input = StringIO.new
		@editor = RawLine::Editor.new(@input, @output)
	end

	it "reads raw characters from @input" do
		@input << "test #1"
		@input.rewind
	 	@editor.read
		expect(@editor.line.text).to eq("test #1")
		expect(@output.string).to eq("test #1\n")
	end

	it "can bind keys to code blocks" do
		@editor.bind(:ctrl_w) { @editor.write "test #2a" }
		@editor.bind(?\C-q) { "test #2b" }
		@editor.bind(21) { "test #2c" }
		@editor.bind([22]) { "test #2d" }
		@editor.terminal.escape_codes = [] # remove any existing escape codes
		expect {@editor.bind({:test => [?\e.ord, ?t.ord, ?e.ord, ?s.ord, ?t.ord]}) { "test #2e" }}.to raise_error(RawLine::BindingException)
		@editor.terminal.escape_codes << ?\e.ord
		expect {@editor.bind({:test => "\etest"}) { "test #2e" }}.to_not raise_error
		expect {@editor.bind("\etest2") { "test #2f" }}.to_not raise_error
		@input << ?\C-w.chr
		@input.rewind
	 	@editor.read
		expect(@editor.line.text).to eq("test #2a")
		@editor.char = [?\C-q.ord]
		expect(@editor.press_key).to eq("test #2b")
		@editor.char = [?\C-u.ord]
		expect(@editor.press_key).to eq("test #2c")
		@editor.char = [?\C-v.ord]
		expect(@editor.press_key).to eq("test #2d")
		@editor.char = [?\e.ord, ?t.ord, ?e.ord, ?s.ord, ?t.ord]
		expect(@editor.press_key).to eq("test #2e")
		@editor.char = [?\e.ord, ?t.ord, ?e.ord, ?s.ord, ?t.ord, ?2.ord]
		expect(@editor.press_key).to eq("test #2f")
	end

	it "keeps track of the cursor position" do
		@input << "test #4"
		@input.rewind
		@editor.read
		expect(@editor.line.position).to eq(7)
		3.times { @editor.move_left }
		expect(@editor.line.position).to eq(4)
		2.times { @editor.move_right }
		expect(@editor.line.position).to eq(6)
	end

	it "can delete characters" do
		@input << "test #5"
		@input.rewind
		@editor.read
		3.times { @editor.move_left }
		4.times { @editor.delete_left_character }
		3.times { @editor.delete_character }
		expect(@editor.line.text).to eq("")
		expect(@editor.line.position).to eq(0)
	end

	it "can clear the whole line" do
		@input << "test #5"
		@input.rewind
		@editor.read
		@editor.clear_line
		expect(@editor.line.text).to eq("")
		expect(@editor.line.position).to eq(0)
	end

	it "supports undo and redo" do
		@input << "test #6"
		@input.rewind
		@editor.read
		3.times { @editor.delete_left_character }
		2.times { @editor.undo }
		expect(@editor.line.text).to eq("test #")
		2.times { @editor.redo }
		expect(@editor.line.text).to eq("test")
	end

	it "supports history" do
		@input << "test #7a"
		@input.rewind
		@editor.read "", true
		@editor.newline
		@input << "test #7b"
		@input.pos = 8
		@editor.read "", true
		@editor.newline
		@input << "test #7c"
		@input.pos = 16
		@editor.read "", true
		@editor.newline
		@input << "test #7d"
		@input.pos = 24
		@editor.read "", true
		@editor.newline
		@editor.history_back
		expect(@editor.line.text).to eq("test #7c")
		10.times { @editor.history_back }
		expect(@editor.line.text).to eq("test #7a")
		2.times { @editor.history_forward }
		expect(@editor.line.text).to eq("test #7c")
	end

	it "can overwrite lines" do
		@input << "test #8a"
		@input.rewind
		@editor.read
		@editor.overwrite_line("test #8b", 2)
		expect(@editor.line.text).to eq("test #8b")
		expect(@editor.line.position).to eq(2)
	end

	it "can complete words" do
		@editor.completion_append_string = "\t"
		@editor.bind(:tab) { @editor.complete }
		@editor.completion_proc = lambda do |word|
	  	if word then
 				['select', 'update', 'delete', 'debug', 'destroy'].find_all	{ |e| e.match(/^#{Regexp.escape(word)}/) }
			end
		end
		@input << "test #9 de" << ?\t.chr << ?\t.chr
		@input.rewind
		@editor.read
		expect(@editor.line.text).to eq("test #9 delete\t")
	end

	it "supports INSERT and REPLACE modes" do
		@input << "test 0"
		@editor.terminal.keys[:left_arrow].each { |k| @input << k.chr }
		@input << "#1"
		@input.rewind
		@editor.read
		expect(@editor.line.text).to eq("test #10")
		@editor.toggle_mode
		@input << "test 0"
		@editor.terminal.keys[:left_arrow].each { |k| @input << k.chr }
		@input << "#1"
		@input.rewind
		@editor.read
		expect(@editor.line.text).to eq("test #1test #1")
	end


end
