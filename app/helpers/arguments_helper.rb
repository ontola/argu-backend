module ArgumentsHelper
private
	def getArgType(argument)
		case argument.argtype
		when 0
			t(:argument_type_scientific)
		when 1
			t(:argument_type_axiomatic)
		when 2
			t(:argument_type_other)
		when 3
			t(:argument_type_discussion)
		else
			t(:argument_type_unknown)
		end
	end

	def getArgImage(argument)
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
