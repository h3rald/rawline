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
					:enter => [?\n]
				})
		end

	end


end
