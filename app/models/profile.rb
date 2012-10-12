class Profile < ActiveRecord::Base
	attr_accessible :name, :picture, :about

	def self.find(id)
		@profile = Profile.find_by_username(id)
		@profile ||= Profile.find_by_id(id)
		@profile ||= super(id)
	end

	def self.find_by_username(user)
		return (User.find_by_username(user)).try(:profile)
	end
end