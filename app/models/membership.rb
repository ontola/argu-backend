# @todo remove after migration
class Membership < ActiveRecord::Base
  include ArguBase, Parentable
  scope :managers, -> { where(role: Membership::ROLES[:manager]) }

  belongs_to :profile
  belongs_to :forum, inverse_of: :memberships

  validates :profile_id, :forum_id, presence: true

  counter_culture :forum
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
