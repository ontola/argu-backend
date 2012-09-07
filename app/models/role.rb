class Role < ActiveRecord::Base
has_and_belongs_to_many :users
attr_accessible :name
before_create :correctName

private
	def correctName
		self.name = self.name.to_s.downcase
	end

end