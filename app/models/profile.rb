class Profile < ActiveRecord::Base
  rolify after_remove: :role_removed, before_add: :role_added
  belongs_to :user
  has_many :votes, as: :voteable
  has_many :memberships, dependent: :destroy
  has_many :organisations, through: :memberships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  mount_uploader :profile_photo, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  pica_pica :profile_photo

  ######Attributes#######
  def display_name
    self.name.presence || self.user.username
  end

  #######Methods########
  def voted_on?(item)
    Vote.where(voter_id: self.id, voter_type: self.class.name,
               voteable_id: item.id, voteable_type: item.class.to_s).last
        .try(:for) == 'pro'
  end


  #######Utility#########
  def self.find_by_username(user)
    return (User.find_by_username(user)).try(:profile)
  end
private

  def role_added(role)
    if self.frozen?
      # Send mail or notification to user that he has been unfrozen
    end
  end

  def role_removed(role)
    if self.frozen?
      # Send mail or notification to user that he has been frozen
    end
  end
end