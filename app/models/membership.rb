# @todo remove after migration
class Membership < ApplicationRecord
  include Parentable
  scope :managers, -> { where(role: Membership::ROLES[:manager]) }

  belongs_to :profile
  belongs_to :forum

  validates :profile_id, :forum_id, presence: true

  parentable :forum

  enum role: {member: 0, manager: 2}

  def publisher_id
    if profile.profileable.is_a?(User)
      profile.profileable.id
    else
      profile.profileable.owner.profileable.id
    end
  end

  def publisher
    if profile.profileable.is_a?(User)
      profile.profileable
    else
      profile.profileable.owner.profileable
    end
  end
end
