class Profile < ActiveRecord::Base
  include ArguBase

  has_one :profileable
  rolify after_remove: :role_removed, before_add: :role_added
  has_many :votes, as: :voter
  has_many :memberships, dependent: :destroy
  has_many :page_memberships, dependent: :destroy
  has_many :forums, through: :memberships
  has_many :pages, inverse_of: :owner
  has_many :activities, as: :owner, dependent: :destroy

  mount_uploader :profile_photo, AvatarUploader
  mount_uploader :cover_photo, CoverUploader

  pica_pica :profile_photo

  #validates :name, presence: true, length: {minimum: 3}
  #validates :about, presence: true

  ######Attributes#######
  def display_name
    self.name.presence || self.owner.try(:display_name)
  end

  def email
    owner.try :email
  end

  def frozen?
    has_role? 'frozen'
  end

  def memberships_ids
    memberships.pluck(:forum_id).join(',').presence
  end

  def username
    owner.try :username
  end

  def owner
    User.where(profile: self).first || Page.where(profile: self).first
  end

  def web_url
    username.presence || owner.try(:web_url).presence || id
  end

  #######Methods########
  def voted_on?(item)
    Vote.where(voter_id: self.id, voter_type: self.class.name,
               voteable_id: item.id, voteable_type: item.class.to_s).last
        .try(:for) == 'pro'
  end

  def votes_questions_motions
    votes.where("voteable_type = 'Question' OR voteable_type = 'Motion'")
  end

  def freeze
    add_role :frozen
  end

  # Returns the preffered forum of the user, based on their last forum visit
  def preferred_forum
    @redis ||= Redis.new
    last_forum = @redis.get("profiles.#{self.id}.last_forum")

    (Forum.find(last_forum) if last_forum.present?) || self.memberships.first.try(:forum) || Forum.first_public
  end

  def member_of?(_forum)
    _forum.present? && self.memberships.where(forum_id: _forum.is_a?(Forum) ? _forum.id : _forum).present?
  end

  def unfreeze
    remove_role :frozen
  end

  # Hasn't been thought through, so disable for the moment.
  def destroy
    false
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