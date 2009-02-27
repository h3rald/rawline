#!usr/bin/env ruby

#
#	windows_terminal.rb
#
# Created by Fabio Cevasco on 2008-03-01.
# Copyright (c) 2008 Fabio Cevasco. All rights reserved.
#
# This is Free Software.  See LICENSE for details.
#

module RawLine
	
	# 
	# This class is used to define all the most common character codes and
	# escape sequences used on Windows systems.
	#
	class WindowsTerminal < Terminal

		def initialize
			super
			@escape_codes = [0, 27, 224]
			@keys.merge!(
				{
					:left_arrow => [224, 75],
					:right_arrow => [224, 77],
					:up_arrow => [224, 72],
					:down_arrow => [224, 80],
					:insert => [224, 82],
					:delete => [224, 83],
					:backspace => [8],
					:enter => [13],
					
					:ctrl_alt_a => [0, 30],
					:ctrl_alt_b => [0, 48],
					:ctrl_alt_c => [0, 46],
					:ctrl_alt_d => [0, 32],
					:ctrl_alt_e => [0, 63],
					:ctrl_alt_f => [0, 33],
					:ctrl_alt_g => [0, 34],
					:ctrl_alt_h => [0, 35],
					:ctrl_alt_i => [0, 23],
					:ctrl_alt_j => [0, 36],
					:ctrl_alt_k => [0, 37],
					:ctrl_alt_l => [0, 26],
					:ctrl_alt_m => [0, 32],
					:ctrl_alt_n => [0, 31],
					:ctrl_alt_o => [0, 24],
					:ctrl_alt_p => [0, 25],
					:ctrl_alt_q => [0, 16],
					:ctrl_alt_r => [0, 19],
					:ctrl_alt_s => [0, 31],
					:ctrl_alt_t => [0, 20],
					:ctrl_alt_u => [0, 22],
					:ctrl_alt_v => [0, 47],
					:ctrl_alt_w => [0, 17],
					:ctrl_alt_x => [0, 45],
					:ctrl_alt_y => [0, 21],
					:ctrl_alt_z => [0, 44]
				})
		end

	end


end
