# frozen_string_literal: true

class Edge < ApplicationRecord
  self.inheritance_column = :owner_type

  define_model_callbacks :trash, only: :after
  define_model_callbacks :untrash, only: :after
  define_model_callbacks :convert

  include Ldable
  include Edgeable::ClassMethods
  include Edgeable::CounterCache
  include Edgeable::Properties
  include Edgeable::PropertyAssociations
  include Parentable
  include Shortnameable
  include Uuidable

  acts_as_followable
  has_ltree_hierarchy
  belongs_to :parent,
             class_name: 'Edge',
             inverse_of: :children
  belongs_to :root,
             -> { where(parent_id: nil) },
             class_name: 'Edge',
             foreign_key: :root_id,
             primary_key: :root_id
  belongs_to :publisher, class_name: 'User', required: true, foreign_key: :publisher_id
  belongs_to :creator, class_name: 'Profile', required: true, foreign_key: :creator_id
  has_many :activities,
           -> { order(:created_at) },
           foreign_key: :trackable_edge_id,
           inverse_of: :trackable,
           dependent: :nullify,
           primary_key: :uuid
  has_many :recipient_activities,
           class_name: 'Activity',
           foreign_key: :recipient_edge_id,
           dependent: :nullify,
           primary_key: :uuid
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id,
           dependent: false
  has_many :exports, dependent: :destroy, primary_key: :uuid
  has_many :favorites, dependent: :destroy, primary_key: :uuid
  has_many :followings,
           class_name: 'Follow',
           inverse_of: :followable,
           dependent: :destroy,
           foreign_key: :followable_id,
           primary_key: :uuid
  has_many :grants, dependent: :destroy, primary_key: :uuid
  has_many :grant_resets, inverse_of: :edge, dependent: :destroy, primary_key: :uuid
  has_many :granted_groups, through: :grants, class_name: 'Group'
  has_many :group_memberships, -> { active }, through: :granted_groups

  has_many_children :arguments, order: order_child_count_sql(:votes_pro)
  has_many_children :pro_arguments
  has_many_children :con_arguments
  has_many_children :blog_posts
  has_many_children :comments
  has_many_children :decisions
  has_many_children :forums, dependent: :restrict_with_exception
  has_many_children :motions
  has_many_children :questions
  has_many_children :vote_events
  has_many_children :votes
  has_many :threads,
           -> { where(in_reply_to_id: nil).includes(:properties).order('edges.created_at ASC') },
           class_name: 'Comment',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_one :top_comment,
          -> { active.order(created_at: :asc).includes(:properties) },
          class_name: 'Comment',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :last_decision,
          -> { order(created_at: :desc).includes(:properties) },
          class_name: 'Decision',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :last_published_decision,
          -> { published.order(created_at: :desc).includes(:properties) },
          class_name: 'Decision',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy
  has_one :default_vote_event,
          class_name: 'VoteEvent',
          foreign_key: :parent_id,
          inverse_of: :parent,
          dependent: :destroy

  default_scope -> { includes(:properties) }
  scope :published, -> { where('edges.is_published = true') }
  scope :unpublished, -> { where('edges.is_published = false') }
  scope :trashed, -> { where('edges.trashed_at IS NOT NULL') }
  scope :untrashed, -> { where('edges.trashed_at IS NULL') }
  scope :expired, -> { where('edges.expires_at <= ?', Time.current) }
  scope :active, -> { published.untrashed }

  validates :parent, presence: true, unless: :root_object?

  before_destroy :reset_persisted_edge
  before_destroy :destroy_children
  before_destroy :destroy_redis_children
  after_initialize :set_root_id, if: :new_record?
  before_create :set_confirmed
  before_save :set_publisher_id

  alias_attribute :body, :description
  alias_attribute :content, :description
  alias_attribute :name, :display_name
  alias_attribute :title, :display_name

  acts_as_sequenced scope: :root_id, column: :fragment
  with_collection :exports

  attr_writer :root
  alias user publisher
  alias profile creator

  def canonical_iri(only_path: false)
    RDF::URI(expand_uri_template(:edges_iri, id: uuid, only_path: only_path))
  end

  def children(*args)
    association(:children).reader(*args)
  end

  def children_count(association)
    children_counts[association.to_s].to_i || 0
  end

  def expired?
    expires_at? && expires_at < Time.current
  end

  def self.filter_property(scope, key, value)
    filtered = scope.references(:properties)
    options = property_options(name: key)
    filtered
      .where(properties: {predicate: options[:predicate].to_s, options[:type] => value})
      .or(filtered.where('properties.predicate != ?', options[:predicate].to_s))
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

  def iri_from_template(opts = {})
    RDF::URI(
      expand_uri_template("#{owner_type.constantize.model_name.route_key}_iri", iri_opts.merge(opts))
    )
  end

  def iri_opts
    {id: fragment, root_id: root.url}
  end

  def is_child_of?(edge)
    ancestor_ids.include?(edge.id)
  end

  def is_trashed?
    @is_trashed ||= trashed_at ? trashed_at <= Time.current : false
  end
  alias is_trashed is_trashed?

  # @return [Array] The ids of (persisted) ancestors, excluding self
  def persisted_ancestor_ids
    parent&.persisted_edge&.path&.split('.')&.map(&:to_i)
  end

  def shortnameable?
    %w[Forum Page].include?(owner_type)
  end

  def parent(*args)
    association(:parent).reader(*args)
  end

  def ancestor(type)
    return self if owner_type == type.to_s.classify
    return parent.ancestor(type) if !root_object? && association_cached?(:parent)
    return persisted_edge&.ancestor(type) unless persisted?
    parent_by_type(type)
  end

  def persisted_edge
    return @persisted_edge if @persisted_edge.present?
    persisted = self
    persisted = persisted.parent until persisted.persisted? || persisted.parent.nil?
    @persisted_edge = persisted if persisted.persisted?
  end

  def persisted_edge=(edge)
    raise "#{edge.class} is not an Edge" unless edge.is_a?(Edge) || edge.nil?
    @persisted_edge = edge
  end

  # Only returns a value when the model has been saved
  def polymorphic_tuple
    [owner_type, owner_id]
  end

  # Calculated the number of unique followers for at least {level}
  # @param [Symbol] level The lowest type of follower to include
  # @return [Integer] The number of followers
  def potential_audience(level = :reactions)
    FollowersCollector.new(resource: self, follow_type: level).count
  end

  def publish!
    return if is_published
    self.class.transaction do
      update!(is_published: true)
      increment_counter_caches unless is_trashed?
    end
    true
  end

  def root(*args)
    return self if parent_id.nil? && parent.nil?
    @root ||= association_cached?(:parent) ? parent.root : association(:root).reader(*args)
  end

  def root_object?
    false
  end

  # @return [Array] The ids of (persisted) ancestors, including self if persisted
  def self_and_ancestor_ids
    persisted_edge.path.split('.').map(&:to_i)
  end

  def self.shortnameable?
    false
  end

  def trash
    return if trashed_at.present?
    self.class.transaction do
      update!(trashed_at: Time.current)
      destroy_notifications if is_loggable?
      decrement_counter_caches if is_published?
      run_callbacks :trash
    end
    true
  end

  def trashed_ancestors
    persisted_edge
      .self_and_ancestors
      .trashed
  end

  def untrash
    return if trashed_at.nil?
    self.class.transaction do
      update!(trashed_at: nil)
      increment_counter_caches if is_published?
      run_callbacks :untrash
    end
    true
  end

  def reload(_opts = {})
    @is_trashed = nil
    @persisted_edge = nil
    @root = nil
    super
  end

  private

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
    if type == :page
      root
    elsif type == :forum
      tenant = Edge.find_by(id: self_and_ancestor_ids[1])
      tenant&.owner_type == 'Forum' ? tenant : nil
    else
      ancestors.find_by(owner_type: type.to_s.classify)
    end
  end

  def set_confirmed
    self.confirmed = user.confirmed?
  end

  def set_root_id
    if root_object?
      uuid = SecureRandom.uuid
      self.uuid = uuid
      self.root_id = uuid
    else
      self.root_id ||= parent&.root_id
    end
  end

  def set_publisher_id
    self.publisher_id = publisher.present? ? publisher.id : 0
  end
end
