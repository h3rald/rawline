#!/usr/local/bin/ruby -w

#
#	vt220_terminal.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module InLine
	
	# 
	# This class is used to define all the most common character codes and
	# escape sequences used on *nix systems.
	#
	class VT220Terminal < Terminal

		def initialize
			super
			@escape_codes = [?\e]
			@keys.merge!(
				{
					:up_arrow => [?\e, ?[, ?A],
					:down_arrow => [?\e, ?[, ?B],
					:right_arrow => [?\e, ?[, ?C],
					:left_arrow => [?\e, ?[, ?D],
					:insert => [?\e, ?[, ?2, ?~],
					:delete => [?\e, ?[, ?3, ?~],
					:backspace => [?\C-?],
					:enter => [?\n],

					:ctrl_alt_a => [?\e, ?\C-a],
					:ctrl_alt_b => [?\e, ?\C-b],
					:ctrl_alt_c => [?\e, ?\C-c],
					:ctrl_alt_d => [?\e, ?\C-d],
					:ctrl_alt_e => [?\e, ?\C-e],
					:ctrl_alt_f => [?\e, ?\C-f],
					:ctrl_alt_g => [?\e, ?\C-g],
					:ctrl_alt_h => [?\e, ?\C-h],
					:ctrl_alt_i => [?\e, ?\C-i],
					:ctrl_alt_j => [?\e, ?\C-j],
					:ctrl_alt_k => [?\e, ?\C-k],
					:ctrl_alt_l => [?\e, ?\C-l],
					:ctrl_alt_m => [?\e, ?\C-m],
					:ctrl_alt_n => [?\e, ?\C-n],
					:ctrl_alt_o => [?\e, ?\C-o],
					:ctrl_alt_p => [?\e, ?\C-p],
					:ctrl_alt_q => [?\e, ?\C-q],
					:ctrl_alt_r => [?\e, ?\C-r],
					:ctrl_alt_s => [?\e, ?\C-s],
					:ctrl_alt_t => [?\e, ?\C-t],
					:ctrl_alt_u => [?\e, ?\C-u],
					:ctrl_alt_v => [?\e, ?\C-v],
					:ctrl_alt_w => [?\e, ?\C-w],
					:ctrl_alt_x => [?\e, ?\C-x],
					:ctrl_alt_y => [?\e, ?\C-y],
					:ctrl_alt_z => [?\e, ?\C-z]			
				})
		end

	end


end
