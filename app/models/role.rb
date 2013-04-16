class Role < ActiveRecord::Base
	has_many :roles_users, dependent: :destroy
	has_many :roles, through: :roles_users
	attr_accessible :name
	before_create :correctName

private
	def correctName
		self.name = self.name.to_s.downcase
	end

end