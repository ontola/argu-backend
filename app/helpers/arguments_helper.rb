module ArgumentsHelper
private
	def getBestComment(argument)
		@comment = argument.root_comments[0]
	end

	def argumentCreatorUsername(argument)
		User.find_by_id(argument.versions.last.whodunnit.to_s).username	
	end

	def getArgType(argument)
		case argument.argtype
		when 0
			t("arguments.type_scientific")
		when 1
			t("arguments.type_axiomatic")
		when 2
			t("arguments.type_other")
		when 3
			t("arguments.type_discussion")
		else
			t("arguments.type_unknown")
		end
	end

	def getArgImage(argument)
		unless argument.nil?
			unless argument.argtype.nil?
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
			else
				false
			end
		else 
			false
		end
	end
end
