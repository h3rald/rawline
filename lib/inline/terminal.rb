#!/usr/bin/ruby

module InLine
	
	class Terminal

		include HighLine::SystemExtensions

		include Mappings
		

		attr_accessor :escape_codes, :keys

		def initialize
			@escape_codes = []
			@keys = {}
			@escape_sequences = []
			@max_sequence_length = 1
			Mappings.constants.each do |c| 
				@keys[:"#{c.downcase}"] = [Mappings.const_get(:"#{c}")]
			end
		end

		def update
			@keys.each_value do |k|
				l = k.length
				if  l > 1 then
					@escape_sequences << k
					@max_sequence_length = l if l > @max_sequence_length
				end
			end
		end

		def send_key(code)
			if @escape_codes.include? code then
				sequence = [code]
				loop do
					c = get_character
					sequence << c
					return sequence if @escape_sequences.include? sequence
					break if sequence.length > @max_sequence_length
				end
			else
				return (@keys.has_value? [code]) ? [code] : nil
			end
		end

	end


end
