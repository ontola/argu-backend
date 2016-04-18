# @todo remove after migration
class PageMembership < ActiveRecord::Base
  include ArguBase
  scope :managers, -> { where(role: Membership::ROLES[:manager]) }

  belongs_to :profile
  belongs_to :page, inverse_of: :memberships

  validates :profile_id, :page_id, presence: true

  enum role: {member: 0, manager: 2} #moderator: 1,
end
