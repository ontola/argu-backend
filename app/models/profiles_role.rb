class ProfilesRole < ActiveRecord::Base
	belongs_to :role
	belongs_to :profile
end