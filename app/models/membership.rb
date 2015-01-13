class Membership < ActiveRecord::Base
  include ArguBase
  scope :managers, -> { where(role: Membership::ROLES[:manager]) }

  belongs_to :profile
  belongs_to :forum, inverse_of: :memberships

  validates :profile_id, :forum_id, presence: true

  counter_culture :forum

  enum role: {member: 0, manager: 2}
end
