# frozen_string_literal: true

class Profile < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Uuidable
  include DependentAssociations

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  # has_one :profileable, class_name: 'User'
  belongs_to :profileable,
             polymorphic: true,
             inverse_of: :profile,
             primary_key: :uuid

  before_destroy :anonymize_dependencies
  has_many :activities, -> { order(:created_at) }, as: :owner, dependent: :restrict_with_exception, inverse_of: :owner
  has_many :group_memberships, -> { active }, foreign_key: :member_id, inverse_of: :member, dependent: :destroy
  has_many :unscoped_group_memberships,
           class_name: 'GroupMembership',
           inverse_of: :member,
           foreign_key: :member_id,
           dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :grants, through: :groups
  has_many :granted_edges_scope, through: :grants, source: :edge, class_name: 'Edge'
  has_many :votes, inverse_of: :creator, foreign_key: :creator_id, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :container_nodes, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :pages, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :topics, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :uploaded_media_objects,
           class_name: 'MediaObject',
           inverse_of: :creator,
           foreign_key: 'creator_id',
           dependent: :restrict_with_exception
  has_many :edges, dependent: :restrict_with_exception, foreign_key: :creator_id, inverse_of: :creator

  delegate :ancestor, :iri, to: :profileable

  auto_strip_attributes :name, squish: true

  COMMUNITY_ID = 0
  ANONYMOUS_ID = -1
  SERVICE_ID = -2
  GUEST_ID = -3

  def as_json(options = {})
    # Hide profileable for the more friendly actor
    super(options.merge(except: %i[profileable profileable_type profileable_id]))
  end

  def confirmed?
    profileable.try :confirmed?
  end

  def display_name
    profileable.try(:display_name) || name.presence
  end

  def email
    profileable.try :email
  end

  def granted_edges(root_id: nil, owner_type: nil, grant_set: nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

  def guest?
    id == GUEST_ID
  end

  # @return [Boolean] Whether the user has a group_membership for the provided group_id
  def is_group_member?(group_id)
    group_ids.include?(group_id)
  end

  # @todo remove when pages are no longer profileable
  def profileable
    ActsAsTenant.without_tenant do
      profileable = super
      profileable.nil? ? association(:profileable).reload&.reader : profileable
    end
  end

  # ######Methods########
  def reserved?
    id <= 0
  end

  class << self
    def anonymous
      Profile.find(Profile::ANONYMOUS_ID)
    end

    def community
      Profile.find(Profile::COMMUNITY_ID)
    end

    def dependent_associations
      @dependent_associations ||= Edge.descendants.map(&:to_s).map(&:tableize) +
        %w[activities uploaded_media_objects unscoped_group_memberships]
    end

    def guest
      Profile.find(Profile::GUEST_ID)
    end

    def includes_for_profileable
      {profileable: {}}
    end

    def service
      Profile.find(Profile::SERVICE_ID)
    end
  end
end
