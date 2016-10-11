# frozen_string_literal: true
class ProfilesRole < ApplicationRecord
  belongs_to :role
  belongs_to :profile

  validates :profile_id, :role_id, presence: true
end
