#!/usr/local/bin/ruby -w

#
#	terminal.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#
#
#
module InLine
	
	# 
	# The Terminal class defines character codes and code sequences which can be
	# bound to actions by editors.
	# An OS-dependent subclass of InLine::Terminal is automatically instantiated by
	# InLine::Editor.
	#
	class Terminal

		include HighLine::SystemExtensions

		attr_accessor :escape_codes
		attr_reader :keys, :escape_sequences

		# 
		# Create an instance of InLine::Terminal.
		#
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
				:ctrl_z => [?\C-z]
				}
			@escape_codes = []
			@escape_sequences = []
			update
		end

		#
		# Update the terminal escape sequences. This method is called automatically
		# by InLine::Editor#bind().
		#
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
