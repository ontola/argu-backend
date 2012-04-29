module ArgumentsHelper
private
	def getArgType(argument)
		if argument.argtype == "ARGUMENT_TYPE_SCIENTIFIC"
			t(:argument_type_scientific)
		elsif argument.argtype == "ARGUMENT_TYPE_AXIOMATIC"
			t(:argument_type_axiomatic)
		elsif argument.argtype == "ARGUMENT_TYPE_OTHER"
			t(:argument_type_other)
		elsif argument.argtype == "ARGUMENT_TYPE_DISCUSSION"
			t(:argument_type_discussion)
		else
			t(:argument_type_unknown)
		end
	end
end
