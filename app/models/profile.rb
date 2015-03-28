class Profile < ActiveRecord::Base
  include ArguBase

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  #has_one :profileable, class_name: 'User'
  belongs_to :profileable, polymorphic: true, inverse_of: :profile
  accepts_nested_attributes_for :profileable
  rolify after_remove: :role_removed, before_add: :role_added
  has_many :votes, as: :voter
  has_many :memberships, dependent: :destroy
  has_many :page_memberships, dependent: :destroy
  has_many :forums, through: :memberships
  has_many :pages, inverse_of: :owner
  has_many :activities, as: :owner, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :group_memberships, foreign_key: :member_id, inverse_of: :member
  has_many :groups, through: :group_memberships

  mount_uploader :profile_photo, AvatarUploader
  mount_uploader :cover_photo, CoverUploader

  pica_pica :profile_photo
  acts_as_follower

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  ######Attributes#######
  def display_name
    self.name.presence || self.profileable.try(:display_name)
  end

  def email
    profileable.try :email
  end

  def frozen?
    has_role? 'frozen'
  end

  def memberships_ids
    memberships.pluck(:forum_id).join(',').presence
  end

  #def owner
  #  self.profileable
  #end

  def url
    profileable.url.presence || id
  end

  # TODO Crashes if false
  def finished_intro?
    self.profileable && self.profileable.finished_intro?
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
    begin
      @redis ||= Redis.new
      last_forum = @redis.get("profiles.#{self.id}.last_forum")
    rescue RuntimeError => e
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, {
          :severity => 'error',
      })
    end

    (Forum.find(last_forum) if last_forum.present?) || self.memberships.first.try(:forum) || Forum.first_public
  end

  def requires_name?
    self.profileable.class == Page
  end

  def member_of?(_forum)
    _forum.present? && self.memberships.where(forum_id: _forum.is_a?(Forum) ? _forum.id : _forum).present?
  end

  def unfreeze
    remove_role :frozen
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