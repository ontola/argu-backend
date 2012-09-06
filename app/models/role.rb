class Role < ActiveRecord::Base
has_and_belongs_to_many :users
attr_accessible :name
before_save :correctName

private
	def self.correctName
		name.to_s.camelize
	end

end