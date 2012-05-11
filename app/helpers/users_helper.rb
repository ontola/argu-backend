module UsersHelper

	def user_type(clearance)
		if clearance == 0
			t(:users_clearance_0)
		elsif clearance == 1
			t(:users_clearance_1)
		elsif clearance == 2
			t(:users_clearance_2)
		elsif clearance == 3
			t(:users_clearance_3)
		elsif clearance == 4
			t(:users_clearance_4)
		elsif clearance == 5
			t(:users_clearance_5)
		elsif clearance == 6
			t(:users_clearance_6)
		elsif clearance == 7
			t(:users_clearance_7)
		elsif clearance == 8
			t(:users_clearance_8)
		end
	end

	def settingsTabCheck(tab)
		if("account".eql?(tab))
			"account"
		elsif("settings".eql?(tab))
			"settings"
		else
			"account"
		end
	end
end
