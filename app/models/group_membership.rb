# frozen_string_literal: true
class GroupMembership < ActiveRecord::Base
  include ArguBase

  belongs_to :profile
  belongs_to :group
  belongs_to :member, inverse_of: :group_memberships, class_name: 'Profile'

  validates :group_id, :member_id, presence: true
end
