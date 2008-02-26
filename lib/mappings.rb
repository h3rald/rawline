#!/usr/bin/ruby

module Inline
	
	module Mappings

		TAB = 9
		ENTER = 13
		ESC = 27
		BACKSPACE = 8
		SPACE = 32

		CTRL_A = 1
		CTRL_B = 2
		CTRL_C = 3
		CTRL_D = 4
		CTRL_E = 5
		CTRL_F = 6
		CTRL_G = 7
		CTRL_H = 8
		CTRL_I = 9
		CTRL_J = 10
		CTRL_K = 11
		CTRL_X = 24
		CTRL_Y = 25
		CTRL_Z = 26

		F1 = 59
		F2 = 60
		F3 = 61
		F4 = 62
		F5 = 63
		F6 = 64
		F7 = 65
		F8 = 66
		F9 = 67
		F10 = 68

		SPECIAL = 224
		LEFT_ARROW = 75
		RIGHT_ARROW = 77
		UP_ARROW = 72
		DOWN_ARROW = 80
		DEL = 83

		def mapped?
			Mappings.constants.each do |c| 
				return true if (Mappings.const_get(:"#{c}") == ("#{Editor.char}"))
			end
			false
		end
	
	end

end
