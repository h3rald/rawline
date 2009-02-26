#!/usr/local/bin/ruby -w

#
#	vt220_terminal.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module RawLine
	
	# 
	# This class is used to define all the most common character codes and
	# escape sequences used on *nix systems.
	#
	class VT220Terminal < Terminal

		def initialize
			super
			@escape_codes = [?\e.ord]
			@keys.merge!(
				{
					:up_arrow => [?\e.ord, ?[.ord, ?A.ord],
					:down_arrow => [?\e.ord, ?[.ord, ?B.ord],
					:right_arrow => [?\e.ord, ?[.ord, ?C.ord],
					:left_arrow => [?\e.ord, ?[.ord, ?D.ord],
					:insert => [?\e.ord, ?[, ?2.ord, ?~.ord],
					:delete => [?\e.ord, ?[, ?3.ord, ?~.ord],
					:backspace => [?\C-?.ord],
					:enter => (HighLine::SystemExtensions::CHARACTER_MODE == 'termios' ? [?\n.ord] : [?\r]),

					:ctrl_alt_a => [?\e.ord, ?\C-a.ord],
					:ctrl_alt_b => [?\e.ord, ?\C-b.ord],
					:ctrl_alt_c => [?\e.ord, ?\C-c.ord],
					:ctrl_alt_d => [?\e.ord, ?\C-d.ord],
					:ctrl_alt_e => [?\e.ord, ?\C-e.ord],
					:ctrl_alt_f => [?\e.ord, ?\C-f.ord],
					:ctrl_alt_g => [?\e.ord, ?\C-g.ord],
					:ctrl_alt_h => [?\e.ord, ?\C-h.ord],
					:ctrl_alt_i => [?\e.ord, ?\C-i.ord],
					:ctrl_alt_j => [?\e.ord, ?\C-j.ord],
					:ctrl_alt_k => [?\e.ord, ?\C-k.ord],
					:ctrl_alt_l => [?\e.ord, ?\C-l.ord],
					:ctrl_alt_m => [?\e.ord, ?\C-m.ord],
					:ctrl_alt_n => [?\e.ord, ?\C-n.ord],
					:ctrl_alt_o => [?\e.ord, ?\C-o.ord],
					:ctrl_alt_p => [?\e.ord, ?\C-p.ord],
					:ctrl_alt_q => [?\e.ord, ?\C-q.ord],
					:ctrl_alt_r => [?\e.ord, ?\C-r.ord],
					:ctrl_alt_s => [?\e.ord, ?\C-s.ord],
					:ctrl_alt_t => [?\e.ord, ?\C-t.ord],
					:ctrl_alt_u => [?\e.ord, ?\C-u.ord],
					:ctrl_alt_v => [?\e.ord, ?\C-v.ord],
					:ctrl_alt_w => [?\e.ord, ?\C-w.ord],
					:ctrl_alt_x => [?\e.ord, ?\C-x.ord],
					:ctrl_alt_y => [?\e.ord, ?\C-y.ord],
					:ctrl_alt_z => [?\e.ord, ?\C-z.ord]			
				})
		end

	end


end
