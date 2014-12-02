class Profile < ActiveRecord::Base
  include ArguBase

  rolify after_remove: :role_removed, before_add: :role_added
  has_many :votes, as: :voter
  has_many :memberships, dependent: :destroy
  has_many :forums, through: :memberships

  mount_uploader :profile_photo, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  pica_pica :profile_photo

  validates :name, presence: true, length: {minimum: 3}
  validates :about, presence: true

  ######Attributes#######
  def display_name
    self.name.presence
  end

  def web_url
    User.where(profile_id: id).first.username || id
  end

  #######Methods########
  def voted_on?(item)
    Vote.where(voter_id: self.id, voter_type: self.class.name,
               voteable_id: item.id, voteable_type: item.class.to_s).last
        .try(:for) == 'pro'
  end

  def frozen?
    has_role? 'frozen'
  end

  def freeze
    add_role :frozen
  end

  def member_of?(forum)
    forum.present? && self.memberships.where(forum_id: forum.id).present?
  end

  def unfreeze
    remove_role :frozen
  end

  def username
    User.where(profile_id: self.id).first.username || Pages.where(profile_id: self.id).first.web_url
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