class ProfilesRole < ActiveRecord::Base
	belongs_to :role
	belongs_to :profile

	validates :profile_id, :role_id, presence: true
end