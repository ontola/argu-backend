# frozen_string_literal: true

class Profile < ApplicationRecord
  enhance ProfilePhotoable
  enhance CoverPhotoable
  enhance Updateable
  enhance Actionable

  include Ldable
  include Uuidable

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  # has_one :profileable, class_name: 'User'
  belongs_to :profileable,
             polymorphic: true,
             inverse_of: :profile,
             primary_key: :uuid

  before_destroy :anonymize_dependencies
  has_many :activities, -> { order(:created_at) }, as: :owner, dependent: :restrict_with_exception
  has_many :group_memberships, -> { active }, foreign_key: :member_id, inverse_of: :member, dependent: :destroy
  has_many :unscoped_group_memberships, class_name: 'GroupMembership', foreign_key: :member_id, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :grants, through: :groups
  has_many :granted_edges_scope, through: :grants, source: :edge, class_name: 'Edge'
  has_many :votes, inverse_of: :creator, foreign_key: :creator_id, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_matches, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :creator,
           foreign_key: 'creator_id',
           dependent: :restrict_with_exception
  has_many :edges, dependent: :restrict_with_exception, foreign_key: :creator_id

  delegate :ancestor, to: :profileable

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  auto_strip_attributes :name, squish: true
  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0
  ANONYMOUS_ID = -1

  def as_json(options = {})
    # Hide profileable for the more friendly actor
    super(options.merge(except: %i[profileable profileable_type profileable_id], methods: %i[actor_type actor_id]))
  end

  # Pages the profile has activities in
  def active_pages(filter = nil)
    page_ids = filter.nil? ? active_pages_ids : filter & active_pages_ids
    Page.where(edges: {uuid: page_ids}).includes(:shortname)
  end

  def active_pages_ids
    @active_page_ids ||=
      activities.where('key IN (?)', Feed::RELEVANT_KEYS).joins(:trackable).pluck('edges.root_id').uniq
  end

  def actor_type
    profileable_type
  end

  def actor_id
    profileable_id
  end

  def self.anonymous
    Profile.find(Profile::ANONYMOUS_ID)
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

  def granted_edges(root_id: nil, owner_type: nil, grant_set: nil)
    @granted_edges ||= {}
    @granted_edges[root_id] ||= {}
    @granted_edges[root_id][owner_type] ||= {}
    return @granted_edges[root_id][owner_type][grant_set] if @granted_edges[root_id][owner_type].key?(grant_set)
    scope = granted_edges_scope
    scope = scope.where(root_id: root_id) if root_id.present?
    scope = scope.where(owner_type: owner_type) if owner_type.present?
    if grant_set.present?
      scope =
        scope
          .joins('INNER JOIN grant_sets ON grants.grant_set_id = grant_sets.id')
          .where(grant_sets: {title: grant_set})
    end
    @granted_edges[root_id][owner_type][grant_set] = scope
  end
  alias granted_records granted_edges

  def granted_record_ids(root_id: nil, owner_type: nil, grant_set: nil)
    granted_edges(root_id: root_id, owner_type: owner_type, grant_set: grant_set).pluck(:id)
  end

  def granted_root_ids(grant_set = :moderator)
    @granted_root_ids ||= {}
    return @granted_root_ids[grant_set] if @granted_root_ids.key?(grant_set)
    scope = granted_edges_scope
    if grant_set.present?
      scope =
        scope
          .joins('INNER JOIN grant_sets ON grants.grant_set_id = grant_sets.id')
          .where(grant_sets: {title: grant_set})
    end
    @granted_root_ids[grant_set] ||= scope.pluck(:root_id).uniq
  end

  def self.includes_for_profileable
    {default_profile_photo: {}, profileable: {}}
  end

  # @return [Boolean] Whether the user has a group_membership for the provided group_id
  def is_group_member?(group_id)
    group_memberships.pluck(:group_id)&.include?(group_id)
  end

  def owner
    profileable
  end
  deprecate :owner

  def url
    profileable.presence && profileable.url.presence
  end

  # ######Methods########
  # Returns the last visted forum
  def last_forum
    forum_id = Argu::Redis.get("profile:#{id}:last_forum")
    Forum.find_by(uuid: forum_id) if uuid?(forum_id)
  end

  # Returns the preferred forum, based the first favorite or the first public forum
  def preferred_forum
    profileable.try(:favorites)&.joins(:edge)&.where(edges: {owner_type: 'Forum'})&.first&.edge ||
      Forum.first_public
  end

  def requires_name?
    profileable.class == Page
  end

  def serializer_class
    "#{profileable.class}Serializer".constantize
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def anonymize_dependencies
    %w[comments motions arguments questions blog_posts vote_events vote_matches activities
       uploaded_media_objects unscoped_group_memberships]
      .each do |association|
      send(association)
        .model
        .anonymize(send(association))
    end
  end
end
