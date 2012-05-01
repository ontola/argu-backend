module ArgumentsHelper
private
	def getArgType(argument)
		if argument.argtype == 0
			t(:argument_type_scientific)
		elsif argument.argtype == 1
			t(:argument_type_axiomatic)
		elsif argument.argtype == 2
			t(:argument_type_other)
		elsif argument.argtype == 3
			t(:argument_type_discussion)
		else
			t(:argument_type_unknown)
		end
	end
end
