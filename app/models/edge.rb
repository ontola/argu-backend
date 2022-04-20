# frozen_string_literal: true

class Edge < ApplicationRecord # rubocop:disable Metrics/ClassLength
  self.inheritance_column = :owner_type

  define_model_callbacks :trash, only: :after
  define_model_callbacks :untrash, only: :after
  define_model_callbacks :convert

  include Broadcastable
  include Edgeable::ClassMethods
  include Edgeable::CounterCache
  include Edgeable::Properties
  include Edgeable::Searchable
  include Parentable
  include Shortnameable
  include Uuidable
  include Cacheable

  enhance Grantable
  enhance Transferable

  collection_options(
    default_filters: {
      NS.argu[:trashed] => [false],
      NS.argu[:isDraft] => [false]
    },
    title: lambda {
      if filter[NS.argu[:isDraft]]&.first.to_s == 'true'
        I18n.t('edges.collection.drafts')
      else
        association_class.plural_label
      end
    },
    parent: -> { ActsAsTenant.current_tenant }
  )
  acts_as_followable
  has_ltree_hierarchy
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  filterable(
    NS.argu[:trashed] => boolean_filter(
      ->(scope) { scope.where.not(trashed_at: nil) },
      ->(scope) { scope.where(trashed_at: nil) },
      visible: lambda {
        !collection.parent.is_a?(Edge) ||
          collection.user_context.has_grant_set?(collection.parent, %i[moderator administrator staff])
      }
    ),
    NS.argu[:isDraft] => boolean_filter(
      ->(scope) { scope.where(is_published: false) },
      ->(scope) { scope.where(is_published: true) },
      visible: false
    ),
    NS.rdfv.type => {
      filter: lambda do |scope, values|
        scope.where(owner_type: values.map(&method(:class_by_iri)).map(&:to_s))
      end,
      visible: false
    }
  )

  belongs_to :parent,
             class_name: 'Edge',
             inverse_of: :children
  belongs_to :publisher,
             class_name: 'User',
             optional: false,
             autosave: false,
             inverse_of: :edges
  belongs_to :creator,
             class_name: 'Profile',
             optional: false,
             autosave: false,
             inverse_of: :edges
  has_many :activities,
           -> { order(:created_at) },
           foreign_key: :trackable_edge_id,
           inverse_of: :trackable,
           dependent: :nullify,
           primary_key: :uuid
  has_many :recipient_activities,
           class_name: 'Activity',
           foreign_key: :recipient_edge_id,
           inverse_of: :recipient,
           dependent: :nullify,
           primary_key: :uuid
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id,
           dependent: false
  has_many :custom_menu_items, dependent: :destroy, primary_key: :uuid
  has_many :navigations_menu_items,
           -> { navigations },
           primary_key: :uuid,
           inverse_of: :resource,
           as: :resource,
           class_name: 'CustomMenuItem'
  has_many :exports, dependent: :destroy, primary_key: :uuid
  has_many :followings,
           class_name: 'Follow',
           inverse_of: :followable,
           dependent: :destroy,
           foreign_key: :followable_id,
           primary_key: :uuid
  has_many :grants, dependent: :destroy, primary_key: :uuid
  has_many :grant_resets, inverse_of: :edge, dependent: :destroy, primary_key: :uuid
  has_many :grant_sets, inverse_of: :page, dependent: :destroy, primary_key: :uuid, foreign_key: :root_id
  has_many :granted_groups, through: :grants, class_name: 'Group', source: :group
  has_many :group_memberships, -> { active }, through: :granted_groups

  has_many_children :arguments, order: order_child_count_sql(:votes_pro)
  has_many_children :pro_arguments
  has_many_children :con_arguments
  has_many_children :blog_posts
  has_many_children :budget_shops
  has_many_children :comments
  has_many_children :container_nodes, dependent: :restrict_with_exception
  has_many_children :coupon_batches
  has_many_children :creative_works
  has_many_children :decisions
  has_many_children :blogs, dependent: :restrict_with_exception
  has_many_children :custom_form_fields
  has_many_children :custom_forms
  has_many_children :forums, dependent: :restrict_with_exception
  has_many_children :open_data_portals, dependent: :restrict_with_exception
  has_many_children :interventions
  has_many_children :intervention_types
  has_many_children :measures
  has_many_children :motions
  has_many_children :offers
  has_many_children :order_details
  has_many_children :orders
  has_many_children :phases
  has_many_children :projects
  has_many_children :questions
  has_many_children :surveys
  has_many_children :submissions
  has_many_children :terms
  has_many_children :topics
  has_many_children :vocabularies
  has_many_children :vote_events
  has_many_children :votes
  has_many :threads,
           -> { where(parent_comment_id: nil).order('edges.created_at ASC') },
           class_name: 'Comment',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_one :top_comment,
          -> { active.order(created_at: :asc) },
          class_name: 'Comment',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :last_decision,
          -> { order(created_at: :desc) },
          class_name: 'Decision',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :last_published_decision,
          -> { published.order(created_at: :desc) },
          class_name: 'Decision',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :default_vote_event,
          -> { order(created_at: :asc) },
          class_name: 'VoteEvent',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy

  scope :published, -> { where('edges.is_published = true') }
  scope :unpublished, -> { where('edges.is_published = false') }
  scope :trashed, -> { where.not('edges.trashed_at' => nil) }
  scope :untrashed, -> { where(edges: {trashed_at: nil}) }
  scope :expired, -> { where('edges.expires_at <= statement_timestamp()') }
  scope :active, -> { published.untrashed }
  scope :search_import, -> { published }

  validates :parent, presence: true, unless: :root_object?

  after_initialize :set_root_id, if: :new_record?
  before_save :set_publisher_id
  before_create :set_confirmed
  after_create :create_menu_item, if: :create_menu_item?
  before_destroy :reset_persisted_edge
  before_destroy :destroy_children
  before_destroy :destroy_redis_children

  alias_attribute :body, :description
  alias_attribute :content, :description
  alias_attribute :name, :display_name
  alias_attribute :title, :display_name

  acts_as_sequenced scope: :root_id, column: :fragment

  attr_writer :root

  alias user publisher
  alias profile creator

  def activity_recipient
    parent.is_a?(Phase) ? parent.parent : parent
  end

  def change_creator(new_owner)
    update!(creator: new_owner)
    try(:argu_publication)&.update!(creator: new_owner)
    activities
      .where(key: %W[#{self.class.name.underscore}.create #{self.class.name.underscore}.publish])
      .find_each { |a| a.update!(owner: new_owner) }

    true
  end

  def children(*args)
    association(:children).reader(*args)
  end

  def children_count(association, include_descendants: false)
    return descendants.active.where(owner_type: association.to_s.classify).count if include_descendants

    children_counts[association.to_s].to_i || 0
  end

  def collection_iri(collection, **opts)
    opts[:root] ||= root

    super
  end

  def display_name
    attributes['display_name']
  end

  def expired?
    expires_at? && expires_at < Time.current
  end

  def has_expired_ancestors?
    persisted_edge
      .self_and_ancestors
      .expired
      .present?
  end

  def has_trashed_ancestors?
    trashed_ancestors.present?
  end

  def has_unpublished_ancestors?
    persisted_edge
      .self_and_ancestors
      .unpublished
      .present?
  end

  def iri(**opts)
    return @iri if @iri && opts.empty?

    iri ||= ActsAsTenant.with_tenant(root || ActsAsTenant.current_tenant) { super }
    @iri = iri if opts.empty?
    iri
  end

  def iri_template_name
    "#{owner_type.constantize.model_name.route_key}_iri"
  end

  def is_child_of?(edge)
    ancestor_ids.include?(edge.id)
  end

  def is_draft?
    new_record?
  end
  alias is_draft is_draft?

  def is_trashed?
    @is_trashed ||= trashed_at ? trashed_at <= Time.current : false
  end
  alias is_trashed is_trashed?

  # @return [Array] The ids of (persisted) ancestors, excluding self
  def persisted_ancestor_ids
    parent&.persisted_edge&.path&.split('.')&.map(&:to_i)
  end

  def parent
    association(:parent).reader
  end

  def ancestor(type)
    return parent if type.nil?
    return self if owner_type == type.to_s.classify
    return parent.ancestor(type) if !root_object? && association_cached?(:parent)
    return persisted_edge&.ancestor(type) unless persisted?

    parent_by_type(type)
  end

  def persisted_edge
    return @persisted_edge if @persisted_edge.present?

    persisted = self
    persisted = persisted.parent until persisted.persisted? || persisted.parent.nil?
    persisted = persisted.root unless persisted.persisted?
    @persisted_edge = persisted if persisted.persisted?
  end

  def persisted_edge=(edge)
    raise "#{edge.class} is not an Edge" unless edge.is_a?(Edge) || edge.nil?

    @persisted_edge = edge
  end

  def pinned
    pinned_at.present?
  end
  alias pinned? pinned

  def pinned=(value)
    self.pinned_at = %w[true 1].include?(value.to_s) ? Time.current : nil
  end

  # Calculated the number of unique followers for at least {level}
  # @param [Symbol] level The lowest type of follower to include
  # @return [Integer] The number of followers
  def potential_audience(level = :reactions)
    @potential_audience ||= {}
    @potential_audience[level] ||= FollowersCollector.new(resource: self, follow_type: level).count
  end

  def publish!
    return if is_published

    self.class.transaction do
      update!(is_published: true)
      increment_counter_caches unless is_trashed?
    end
    true
  end

  def root # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    return self if root_object? && parent_id.nil? && parent.nil?
    return @root || super if association_cached?(:root)
    return ActsAsTenant.current_tenant if ActsAsTenant.current_tenant&.uuid == root_id

    @root ||= association_cached?(:parent) && parent ? parent.root : association(:root).reader
  end

  def root_object?
    false
  end

  # @return [Array] The ids of (persisted) ancestors, including self if persisted
  def self_and_ancestor_ids
    persisted_edge.path.split('.').map(&:to_i)
  end

  def to_param
    url || fragment
  end

  def trashed_ancestors
    persisted_edge
      .self_and_ancestors
      .trashed
  end

  def reload(**_opts)
    @is_trashed = nil
    @persisted_edge = nil
    @root = nil
    super
  end

  private

  def create_menu_item
    custom_menu_items.create(
      menu_type: 'navigations',
      resource: parent,
      edge: self
    )
  end

  def create_menu_item?
    false
  end

  def destroy_children
    return if owner_type == 'Page'

    children.destroy_all
  end

  def destroy_redis_children
    keys = RedisResource::Key.new(parent: self, root_id: root_id).matched_keys.map(&:key)
    Argu::Redis.redis_instance.del(*keys) if keys.present?
  end

  def reset_persisted_edge
    @persisted_edge = nil
  end

  def parent_by_type(type)
    case type
    when :page
      root
    when :forum
      tenant = Edge.find_by(id: self_and_ancestor_ids[1])
      tenant&.owner_type == 'Forum' ? tenant : nil
    else
      ancestors.find_by(owner_type: type.to_s.classify)
    end
  end

  def set_confirmed
    self.confirmed = user&.confirmed? || false
  end

  def set_root_id
    if root_object?
      uuid = SecureRandom.uuid
      self.uuid ||= uuid
      self.root_id = self.uuid
    else
      self.root_id ||= parent&.root_id
    end
  end

  def set_publisher_id
    self.publisher_id = publisher.present? ? publisher.id : 0
  end
end
