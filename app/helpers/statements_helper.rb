module StatementsHelper
private
	def getStateType(statetype)
		case statetype
		when 0
			t(:statement_type_social)
		when 1
			t(:statement_type_political)
		when 2
			t(:statement_type_jurisdictional)
		when 3
			t(:statement_type_economical)
		when 4
			t(:statement_type_ecological)
		when 5
			t(:statement_type_technological)
		when 6
			t(:statement_type_discussion)
		when 7
			t(:statement_type_other)
		end
	end

	def getStateImage(statetype)
		case statetype
		when 0
			"\\assets\\icon_state_soc.png"
		when 1
			"\\assets\\icon_state_pol.png"
		when 2
			"\\assets\\icon_state_jur.png"
		when 3
			"\\assets\\icon_state_ecn.png"
		when 4
			"\\assets\\icon_state_ecl.png"
		when 5
			"\\assets\\icon_state_tec.png"
		when 6
			"\\assets\\icon_state_dis.png"
		when 7
			"\\assets\\icon_state_oth.png"
		end
	end
end
