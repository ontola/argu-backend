# frozen_string_literal: true
class GroupMembership < ApplicationRecord
  include Parentable

  belongs_to :group
  belongs_to :member,
             inverse_of: :group_memberships,
             class_name: 'Profile'
  belongs_to :profile
  has_one :page,
          through: :group
  has_one :user,
          through: :member,
          source: :profileable,
          source_type: :User
  has_many :grants, through: :group

  validates :group_id, :member_id, presence: true

  paginates_per 30
  parentable :group

  def publisher
    edge.user
  end
end
