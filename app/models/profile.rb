# frozen_string_literal: true

class Profile < ApplicationRecord
  include Ldable
  include ProfilePhotoable
  include Photoable

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  # has_one :profileable, class_name: 'User'
  belongs_to :profileable,
             polymorphic: true,
             inverse_of: :profile
  rolify after_remove: :role_removed, before_add: :role_added

  before_destroy :anonymize_dependencies
  has_many :activities, -> { order(:created_at) }, as: :owner, dependent: :restrict_with_exception
  has_many :group_memberships, -> { active }, foreign_key: :member_id, inverse_of: :member
  has_many :unscoped_group_memberships, class_name: 'GroupMembership', foreign_key: :member_id
  has_many :groups, through: :group_memberships
  has_many :edges, through: :groups
  has_many :grants, through: :groups
  has_many :granted_edges_scope, through: :grants, source: :edge, class_name: 'Edge'
  has_many :pages, inverse_of: :owner, foreign_key: :owner_id, dependent: :restrict_with_exception
  has_many :votes, inverse_of: :creator, foreign_key: :creator_id, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :projects, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_matches, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :creator,
           foreign_key: 'creator_id',
           dependent: :restrict_with_exception

  delegate :context_id, to: :profileable

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  auto_strip_attributes :name, squish: true
  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0

  def as_json(options = {})
    # Hide profileable for the more friendly actor
    super(options.merge(except: %i[profileable profileable_type profileable_id], methods: %i[actor_type actor_id]))
  end

  def actor_type
    profileable_type
  end

  def actor_id
    profileable_id
  end

  def self.community
    Profile.find(Profile::COMMUNITY_ID)
  end

  def confirmed?
    profileable.try :confirmed?
  end

  # http://schema.org/description
  def description
    about
  end

  def display_name
    profileable.try(:display_name) || name.presence
  end

  def email
    profileable.try :email
  end

  def forums
    granted_records('Forum')
  end

  def granted_edges(owner_type = nil, role = nil)
    scope = granted_edges_scope
    scope = scope.where(owner_type: owner_type) if owner_type.present?
    scope = scope.where(grants: {role: Grant.roles[role]}) if role.present?
    scope
  end

  def granted_records(owner_type, role = nil)
    owner_type.constantize.where(id: granted_record_ids(owner_type, role))
  end

  def granted_record_ids(owner_type, role = nil)
    granted_edges(owner_type, role).pluck(:owner_id)
  end

  def self.includes_for_profileable
    {default_profile_photo: {}, profileable: :shortname}
  end

  def owner
    profileable
  end
  deprecate :owner

  def page_ids(role = :manager)
    @page_ids ||= {}
    @page_ids[role] ||= granted_record_ids('Page', role)
  end

  def profile_frozen?
    has_role? 'frozen'
  end

  def url
    profileable.presence && profileable.url.presence
  end

  # TODO: Crashes if false
  delegate :finished_intro?, to: :profileable

  # ######Methods########
  def voted_on?(item)
    Vote.where(creator_id: id,
               voteable_id: item.id,
               voteable_type: item.class.to_s)
      .last
      .try(:for) == 'pro'
  end

  # Warn: Doesn't check for parent deletion
  def votes_questions_motions
    votes.where("voteable_type = 'Question' OR voteable_type = 'Motion'")
  end

  def freeze
    add_role :frozen
  end

  # Returns the last visted forum
  def last_forum
    forum_id = Argu::Redis.get("profile:#{id}:last_forum")
    Forum.find_by(id: forum_id) if forum_id.present?
  end

  # Returns the preferred forum, based the first favorite or the first public forum
  def preferred_forum
    profileable.try(:favorites)&.joins(:edge)&.where(edges: {owner_type: 'Forum'})&.first&.edge&.owner ||
      Forum.first_public
  end

  def requires_name?
    profileable.class == Page
  end

  def member_of?(tenant)
    tenant.present? && granted_edges(nil, 'member').include?(tenant.edge)
  end

  def owner_of(tenant)
    return false if tenant.blank?
    case tenant
    when Forum
      self == tenant.page.owner
    when Page
      self == tenant.owner
    end
  end

  def unfreeze
    remove_role :frozen
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def anonymize_dependencies
    %w[comments motions arguments questions blog_posts projects vote_events vote_matches activities
       uploaded_media_objects unscoped_group_memberships]
      .each do |association|
      send(association)
        .model
        .anonymize(send(association))
    end
  end

  def role_added(role)
    # if self.profile_frozen?
    # Send mail or notification to user that he has been unfrozen
    # end
  end

  def role_removed(role)
    # if self.profile_frozen?
    # Send mail or notification to user that he has been frozen
    # end
  end
end
