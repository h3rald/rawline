#!/usr/bin/env ruby

require 'rubygems'
require 'highline'

require_relative "../lib/rawline/history_buffer.rb"
require_relative "../lib/rawline/line.rb"

describe RawLine::Line do

	before :each do
		@line = RawLine::Line.new(5) {|l| l.prompt = "=>" }
	end

	it "allows characters to be added to @text via the '<<' operator" do
		@line.text = "test #1"
		@line << 'a'[0]
		expect(@line.text).to eq("test #1a")
	end

	it "allows characters to be retrieved and substituted via '[]' and '[]=' operators" do
		@line.text = 'test #2'
		@line[0] = 't'
		expect(@line[0..3]).to eq('test')
		@line[4..6] = ''
		@line[0] = "This is a t"
		expect(@line.text).to eq("This is a test")
	end

	it "updates @position via 'left' and 'right'" do
		@line.text = "test #3"
		@line.right 2
		expect(@line.position).to eq(2)
		@line.left
		expect(@line.position).to eq(1)
		@line.left 4
		expect(@line.position).to eq(0)
		@line.right HighLine::SystemExtensions.terminal_size()[0]+10
		expect(@line.position).to eq(HighLine::SystemExtensions.terminal_size()[0]-2)
		expect(@line.eol).to eq(6)
	end

	it "is aware of the word in which the cursor is" do
		@line.text = "This is another test"
		expect(@line.word).to eq({:start => 0, :end => 3, :text => "This"})
		@line.right 2
		expect(@line[2]).to eq('i'[0])
		expect(@line.word).to eq({:start => 0, :end => 3, :text => "This"})
		@line.right
		expect(@line.word).to eq({:start => 0, :end => 3, :text => "This"})
		@line.right
		expect(@line.word).to eq({:start => 0, :end => 3, :text => "This"})
		@line.right
		expect(@line.word).to eq({:start => 5, :end => 6, :text => "is"})
	end

end
