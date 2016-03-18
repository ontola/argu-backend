class Profile < ActiveRecord::Base
  include ArguBase

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  #has_one :profileable, class_name: 'User'
  belongs_to :profileable, polymorphic: true, inverse_of: :profile
  rolify after_remove: :role_removed, before_add: :role_added

  before_destroy :anonymize_or_wipe_dependencies
  has_many :access_tokens, dependent: :destroy
  has_many :activities, as: :owner, dependent: :destroy
  has_many :forums, through: :memberships
  has_many :group_memberships, foreign_key: :member_id, inverse_of: :member, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :memberships, dependent: :destroy
  has_many :managerships, -> { where(role: Membership.roles[:manager]) }, class_name: 'Membership'
  has_many :page_memberships, dependent: :destroy
  has_many :page_managerships, -> { where(role: PageMembership.roles[:manager]) }, class_name: 'PageMembership'
  has_many :pages, inverse_of: :owner, foreign_key: :owner_id, dependent: :restrict_with_exception
  has_many :votes, as: :voter, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :group_responses, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :projects, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  accepts_nested_attributes_for :profileable

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  auto_strip_attributes :name, :squish => true
  auto_strip_attributes :about, :nullify => false

  mount_uploader :profile_photo, AvatarUploader
  mount_uploader :cover_photo, CoverUploader

  def as_json(options)
    # Hide profileable for the more friendly actor
    super(options.merge(except: [:profileable, :profileable_type, :profileable_id], methods: [:actor_type, :actor_id]))
  end

  def actor_type
    profileable_type
  end

  def actor_id
    profileable_id
  end

  def confirmed?
    profileable.try :confirmed?
  end

  # http://schema.org/description
  def description
    self.about
  end

  def display_name
    self.profileable.try(:display_name) || self.name.presence
  end

  def email
    profileable.try :email
  end

  def profile_frozen?
    has_role? 'frozen'
  end

  def memberships_ids
    memberships.pluck(:forum_id).join(',').presence
  end

  def owner
    self.profileable
  end
  deprecate :owner

  def url
    profileable.presence && profileable.url.presence
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

  # Warn: Doesn't check for parent deletion
  def votes_questions_motions
    votes.where("voteable_type = 'Question' OR voteable_type = 'Motion'")
  end

  def freeze
    add_role :frozen
  end

  # Returns the preffered forum of the user, based on their last forum visit
  def preferred_forum
    last_forum = Argu::Redis.get("profile:#{self.id}:last_forum")

    (Forum.find_by(id: last_forum) if last_forum.present?) || self.memberships.first.try(:forum) || Forum.first_public
  end

  def requires_name?
    self.profileable.class == Page
  end

  def member_of?(_forum)
    _forum.present? && self.memberships.where(forum_id: _forum.is_a?(Forum) ? _forum.id : _forum).present?
  end

  def owner_of(forum)
    self == forum.page.owner
  end

  def unfreeze
    remove_role :frozen
  end

private

  # Sets the dependent foreign relations to a public profile
  # Except for comments..
  def anonymize_or_wipe_dependencies
    %w(comments motions arguments questions blog_posts projects).each do |association|
      association
          .classify
          .constantize
          .anonymize(self.send(association))
    end
    reload
  end

  def role_added(role)
    if self.profile_frozen?
      # Send mail or notification to user that he has been unfrozen
    end
  end

  def role_removed(role)
    if self.profile_frozen?
      # Send mail or notification to user that he has been frozen
    end
  end
end
