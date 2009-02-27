#!usr/bin/env ruby

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
module RawLine
	
	# 
	# The Terminal class defines character codes and code sequences which can be
	# bound to actions by editors.
	# An OS-dependent subclass of RawLine::Terminal is automatically instantiated by
	# RawLine::Editor.
	#
	class Terminal

		include HighLine::SystemExtensions

		attr_accessor :escape_codes
		attr_reader :keys, :escape_sequences

		# 
		# Create an instance of RawLine::Terminal.
		#
		def initialize
			@keys = 
				{
				:tab => [?\t.ord],
				:return => [?\r.ord],
				:newline => [?\n.ord],
				:escape => [?\e.ord],

				:ctrl_a => [?\C-a.ord],
				:ctrl_b => [?\C-b.ord],
				:ctrl_c => [?\C-c.ord],
				:ctrl_d => [?\C-d.ord],
				:ctrl_e => [?\C-e.ord],
				:ctrl_f => [?\C-f.ord],
				:ctrl_g => [?\C-g.ord],
				:ctrl_h => [?\C-h.ord],
				:ctrl_i => [?\C-i.ord],
				:ctrl_j => [?\C-j.ord],
				:ctrl_k => [?\C-k.ord],
				:ctrl_l => [?\C-l.ord],
				:ctrl_m => [?\C-m.ord],
				:ctrl_n => [?\C-n.ord],
				:ctrl_o => [?\C-o.ord],
				:ctrl_p => [?\C-p.ord],
				:ctrl_q => [?\C-q.ord],
				:ctrl_r => [?\C-r.ord],
				:ctrl_s => [?\C-s.ord],
				:ctrl_t => [?\C-t.ord],
				:ctrl_u => [?\C-u.ord],
				:ctrl_v => [?\C-v.ord],
				:ctrl_w => [?\C-w.ord],
				:ctrl_x => [?\C-x.ord],
				:ctrl_y => [?\C-y.ord],
				:ctrl_z => [?\C-z.ord]
				}
			@escape_codes = []
			@escape_sequences = []
			update
		end

		#
		# Update the terminal escape sequences. This method is called automatically
		# by RawLine::Editor#bind().
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
