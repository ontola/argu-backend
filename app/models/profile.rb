class Profile < ActiveRecord::Base
	attr_accessible :name, :picture, :about

	def self.find_by_username(user)
		return (User.find_by_username(user)).try(:profile)
	end
end