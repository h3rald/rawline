#!/usr/local/bin/ruby -w

module InLine
	
	class Terminal

		include HighLine::SystemExtensions

		

		attr_accessor :escape_codes
		attr_reader :keys, :escape_sequences

		def initialize
			@keys = 
				{
				:tab => [?\t],
				:return => [?\r],
				:newline => [?\n],
				:escape => [?\e],

				:ctrl_a => [?\C-a],
				:ctrl_b => [?\C-b],
				:ctrl_c => [?\C-c],
				:ctrl_d => [?\C-d],
				:ctrl_e => [?\C-e],
				:ctrl_f => [?\C-f],
				:ctrl_g => [?\C-g],
				:ctrl_h => [?\C-h],
				:ctrl_i => [?\C-i],
				:ctrl_j => [?\C-j],
				:ctrl_k => [?\C-k],
				:ctrl_l => [?\C-l],
				:ctrl_m => [?\C-m],
				:ctrl_n => [?\C-n],
				:ctrl_o => [?\C-o],
				:ctrl_p => [?\C-p],
				:ctrl_q => [?\C-q],
				:ctrl_r => [?\C-r],
				:ctrl_s => [?\C-s],
				:ctrl_t => [?\C-t],
				:ctrl_u => [?\C-u],
				:ctrl_v => [?\C-v],
				:ctrl_w => [?\C-w],
				:ctrl_x => [?\C-x],
				:ctrl_y => [?\C-y],
				:ctrl_z => [?\C-z],

				:alt_a => [?\M-a],
				:alt_b => [?\M-b],
				:alt_c => [?\M-c],
				:alt_d => [?\M-d],
				:alt_e => [?\M-e],
				:alt_f => [?\M-f],
				:alt_g => [?\M-g],
				:alt_h => [?\M-h],
				:alt_i => [?\M-i],
				:alt_j => [?\M-j],
				:alt_k => [?\M-k],
				:alt_l => [?\M-l],
				:alt_m => [?\M-m],
				:alt_n => [?\M-n],
				:alt_o => [?\M-o],
				:alt_p => [?\M-p],
				:alt_q => [?\M-q],
				:alt_r => [?\M-r],
				:alt_s => [?\M-s],
				:alt_t => [?\M-t],
				:alt_u => [?\M-u],
				:alt_v => [?\M-v],
				:alt_w => [?\M-w],
				:alt_x => [?\M-x],
				:alt_y => [?\M-y],
				:alt_z => [?\M-z],

				:ctrl_alt_a => [?\C-\M-a],
				:ctrl_alt_b => [?\C-\M-b],
				:ctrl_alt_c => [?\C-\M-c],
				:ctrl_alt_d => [?\C-\M-d],
				:ctrl_alt_e => [?\C-\M-e],
				:ctrl_alt_f => [?\C-\M-f],
				:ctrl_alt_g => [?\C-\M-g],
				:ctrl_alt_h => [?\C-\M-h],
				:ctrl_alt_i => [?\C-\M-i],
				:ctrl_alt_j => [?\C-\M-j],
				:ctrl_alt_k => [?\C-\M-k],
				:ctrl_alt_l => [?\C-\M-l],
				:ctrl_alt_m => [?\C-\M-m],
				:ctrl_alt_n => [?\C-\M-n],
				:ctrl_alt_o => [?\C-\M-o],
				:ctrl_alt_p => [?\C-\M-p],
				:ctrl_alt_q => [?\C-\M-q],
				:ctrl_alt_r => [?\C-\M-r],
				:ctrl_alt_s => [?\C-\M-s],
				:ctrl_alt_t => [?\C-\M-t],
				:ctrl_alt_u => [?\C-\M-u],
				:ctrl_alt_v => [?\C-\M-v],
				:ctrl_alt_w => [?\C-\M-w],
				:ctrl_alt_x => [?\C-\M-x],
				:ctrl_alt_y => [?\C-\M-y],
				:ctrl_alt_z => [?\C-\M-z]	
				}
			@escape_codes = []
			@escape_sequences = []
			update
		end

		def update
			@keys.each_value do |k|
				l = k.length
				if  l > 1 then
					@escape_sequences << k unless @escape_sequences.include? k
				end
			end
		end

	end


end
