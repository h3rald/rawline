#!/usr/bin/ruby

module InLine
	
	class Terminal

		include HighLine::SystemExtensions

		include Mappings
		

		attr_accessor :escape_codes, :keys

		def initialize(max_sequence_length=11)
			@escape_codes = []
			@keys = {}
			@max_sequence_length = max_sequence_length
			Mappings.constants.each do |c| 
				@keys[:"#{c.downcase}"] = Mappings.const_get(:"#{c}")
			end
		end

		def send_key(code)
			if @escape_codes.include? code then
				sequence = [code]
				loop do
					c = get_character
					sequence << c
					return sequence if @keys.has_value? sequence
					break if sequence.length > @max_sequence_length
				end
			end
			return [code] if @keys.has_value? code
			return nil
		end

	end


end
