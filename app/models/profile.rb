# frozen_string_literal: true

class Profile < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance ProfilePhotoable
  enhance CoverPhotoable
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Updatable

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
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :creator,
           foreign_key: 'creator_id',
           dependent: :restrict_with_exception
  has_many :edges, dependent: :restrict_with_exception, foreign_key: :creator_id

  delegate :ancestor, :iri, to: :profileable

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  auto_strip_attributes :name, squish: true
  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0
  ANONYMOUS_ID = -1
  SERVICE_ID = -2

  def as_json(options = {})
    # Hide profileable for the more friendly actor
    super(options.merge(except: %i[profileable profileable_type profileable_id], methods: %i[actor_type actor_id]))
  end

  # Pages the profile has activities in
  def active_pages(filter = nil)
    ActsAsTenant.without_tenant do
      page_ids = filter.nil? ? active_pages_ids : filter & active_pages_ids
      Page.where(edges: {uuid: page_ids}).includes(:shortname)
    end
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
    @anonymous ||= Profile.find(Profile::ANONYMOUS_ID)
  end

  def self.community
    @community ||= Profile.find(Profile::COMMUNITY_ID)
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

  def granted_edges(root_id: nil, owner_type: nil, grant_set: nil) # rubocop:disable Metrics/AbcSize
    grant_set ||= %w[spectator participator initiator moderator administrator]
    @granted_edges ||= {}
    @granted_edges[root_id] ||= {}
    @granted_edges[root_id][owner_type] ||= {}
    return @granted_edges[root_id][owner_type][grant_set] if @granted_edges[root_id][owner_type].key?(grant_set)
    scope = granted_edges_scope
    scope = scope.where(root_id: root_id) if root_id.present?
    scope = scope.where(owner_type: owner_type) if owner_type.present?
    raise 'not grant_set given' if grant_set.blank?
    scope =
      scope
        .joins('INNER JOIN grant_sets ON grants.grant_set_id = grant_sets.id')
        .where(grant_sets: {title: grant_set})
    @granted_edges[root_id][owner_type][grant_set] = scope
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
    group_ids.include?(group_id)
  end

  def owner
    profileable
  end
  deprecate :owner

  # @todo remove when pages are no longer profileable
  def profileable
    ActsAsTenant.without_tenant do
      profileable = super
      profileable.nil? ? association(:profileable).reload&.reader : profileable
    end
  end

  def self.service
    Profile.find(Profile::SERVICE_ID)
  end

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
    ActsAsTenant.without_tenant do
      profileable.try(:favorites)&.joins(:edge)&.where(edges: {owner_type: 'Forum'})&.first&.edge ||
        Forum.first_public
    end
  end

  def requires_name?
    profileable.class == Page
  end

  def reserved?
    id <= 0
  end

  def serializer_class
    "#{profileable.class}Serializer".constantize
  end

  def vote_cache
    @vote_cache ||= VoteCache.new(self)
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def anonymize_dependencies
    ActsAsTenant.without_tenant do
      %w[comments motions arguments questions blog_posts vote_events activities
         uploaded_media_objects unscoped_group_memberships]
        .each do |association|
        send(association)
          .model
          .anonymize(send(association))
      end
    end
  end

  class << self
    def show_includes
      Page.show_includes + User.show_includes
    end
  end
end
