module VoteHelper

	def getimage(argument)
		case argument.argtype
		when 0
			"\\assets\\icon_sci.png"
		when 1
			"\\assets\\icon_axi.png"
		when 2
			"\\assets\\icon_oth.png"
		when 3
			"\\assets\\icon_dis.png"
		end
	end
end
