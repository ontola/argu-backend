class GroupMembership < ActiveRecord::Base
  include ArguBase

  belongs_to :profile
  belongs_to :group
  belongs_to :page, inverse_of: :group_memberships

  validates :group_id, :page_id, presence: true

end
