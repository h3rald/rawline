#!/usr/bin/env ruby

require_relative "../lib/rawline/history_buffer.rb"

describe RawLine::HistoryBuffer do

	before :each do
		@history = RawLine::HistoryBuffer.new(5)
	end

	it "instantiates an empty array when created" do
		expect(@history.length).to eq(0)
	end

	it "allows items to be added to the history" do
		@history.duplicates = false
		@history << "line #1"
		@history << "line #2"
		@history << "line #3"
		@history << "line #2"
		expect(@history).to eq(["line #1", "line #3", "line #2"])
		@history.duplicates = true
		@history << "line #3"
		expect(@history).to eq(["line #1", "line #3", "line #2", "line #3"])
		@history.exclude = lambda { |i| i.match(/line #[456]/) }
		@history << "line #4"
		@history << "line #5"
		@history << "line #6"
		expect(@history).to eq(["line #1", "line #3", "line #2", "line #3"])
	end

	it "does not overflow" do
		@history << "line #1"
		@history << "line #2"
		@history << "line #3"
		@history << "line #4"
		@history << "line #5"
		@history << "line #6"
		expect(@history.length).to eq(5)
	end

	it "allows navigation back and forward" do
		@history.back
		@history.forward
		expect(@history.position).to eq(nil)
		@history << "line #1"
		@history << "line #2"
		@history << "line #3"
		@history << "line #4"
		@history << "line #5"
		@history.back
		@history.back
		@history.back
		@history.back
		@history.back
		expect(@history.position).to eq(0)
		@history.back
		expect(@history.position).to eq(0)
		@history.forward
		expect(@history.position).to eq(1)
		@history.forward
		@history.forward
		@history.forward
		@history.forward
		expect(@history.position).to eq(4)
		@history.forward
		expect(@history.position).to eq(4)
		@history.cycle = true
		@history.forward
		@history.forward
		expect(@history.position).to eq(1)
	end

	it "can retrieve the last element or the element at @position via 'get'" do
		expect(@history.get).to eq(nil)
		@history << "line #1"
		@history << "line #2"
		@history << "line #3"
		@history << "line #4"
		@history << "line #5"
		expect(@history.get).to eq("line #5")
		@history.back
		expect(@history.get).to eq("line #4")
		@history.forward
		expect(@history.get).to eq("line #5")
	end

	it "can be cleared and resized" do
		@history << "line #1"
		@history << "line #2"
		@history << "line #3"
		@history << "line #4"
		@history << "line #5"
		@history.back
		@history.back
		expect(@history.get).to eq("line #4")
		@history.resize(6)
		expect(@history.position).to eq(nil)
		@history << "line #6"
		expect(@history.get).to eq("line #6")
		@history.empty
		expect(@history).to eq([])
		expect(@history.size).to eq(6)
		expect(@history.position).to eq(nil)
	end
end
