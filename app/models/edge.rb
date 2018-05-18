# frozen_string_literal: true

class Edge < ApplicationRecord
  self.inheritance_column = :owner_type

  include Edgeable::ClassMethods
  include Edgeable::CounterCache
  include Edgeable::Properties
  include Placeable
  include Ldable
  include Shortnameable
  include ProfilePhotoable
  include Photoable
  include Attachable
  include Uuidable
  include Widgetable

  has_ltree_hierarchy
  belongs_to :owner,
             inverse_of: :edge,
             polymorphic: true,
             required: true,
             dependent: :destroy
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
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy,
           primary_key: :uuid
  has_many :grants, dependent: :destroy, primary_key: :uuid
  has_many :grant_resets, inverse_of: :edge, dependent: :destroy, primary_key: :uuid
  has_many :groups, through: :grants
  has_many :group_memberships, -> { active }, through: :groups
  has_many :publications,
           foreign_key: :publishable_id,
           dependent: :destroy,
           primary_key: :uuid
  has_many :published_publications,
           -> { where('publications.published_at IS NOT NULL') },
           class_name: 'Publication',
           foreign_key: :publishable_id,
           primary_key: :uuid
  has_one :argu_publication,
          -> { where(channel: 'argu') },
          class_name: 'Publication',
          foreign_key: :publishable_id,
          primary_key: :uuid
  # Children associations
  has_many :arguments,
           -> { where(owner_type: 'Argument') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :pro_arguments,
           -> { join_owner('Argument').where(arguments: {type: 'ProArgument'}) },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :con_arguments,
           -> { join_owner('Argument').where(arguments: {type: 'ConArgument'}) },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :blog_posts,
           -> { where(owner_type: 'BlogPost') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :comments,
           -> { join_owner('Comment').where(comments: {parent_id: nil}) },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :discussions,
           -> { where(owner_type: %w[Motion Question]) },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_one :top_comment,
          -> { join_owner('Comment').active.where(parent_id: nil).order('comments.created_at ASC') },
          class_name: 'Edge',
          foreign_key: :parent_id,
          inverse_of: :parent
  has_many :decisions,
           -> { where(owner_type: 'Decision') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_one :last_decision,
          -> { join_owner('Decision').order('decisions.step DESC') },
          class_name: 'Edge',
          foreign_key: :parent_id,
          inverse_of: :parent
  has_one :last_published_decision,
          -> { join_owner('Decision').published.order('decisions.step DESC') },
          class_name: 'Edge',
          foreign_key: :parent_id,
          inverse_of: :parent
  has_many :forums,
           -> { where(owner_type: 'Forum') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :motions,
           -> { where(owner_type: 'Motion') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :questions,
           -> { where(owner_type: 'Question') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_many :vote_events,
           -> { where(owner_type: 'VoteEvent') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent
  has_one :default_vote_event,
          -> { where(owner_type: 'VoteEvent') },
          foreign_key: :parent_id,
          class_name: 'Edge',
          inverse_of: :parent
  has_many :votes,
           -> { where(owner_type: 'Vote') },
           class_name: 'Edge',
           foreign_key: :parent_id,
           inverse_of: :parent

  scope :published, -> { where('edges.is_published = true') }
  scope :unpublished, -> { where('edges.is_published = false') }
  scope :trashed, -> { where('edges.trashed_at IS NOT NULL') }
  scope :untrashed, -> { where('edges.trashed_at IS NULL') }
  scope :expired, -> { where('edges.expires_at <= ?', Time.current) }
  scope :active, -> { published.untrashed }
  accepts_nested_attributes_for :argu_publication

  validates :parent, presence: true, unless: :root_object?
  validates :placements, presence: true, if: :requires_location?

  before_destroy :decrement_counter_caches, unless: :is_trashed?
  before_destroy :reset_persisted_edge
  before_destroy :destroy_children
  before_destroy :destroy_redis_children
  after_initialize :set_root_id, if: :new_record?
  before_create :set_confirmed
  before_save :set_user_id

  alias_attribute :content, :description
  alias_attribute :body, :description
  alias_attribute :name, :display_name
  alias_attribute :title, :display_name

  acts_as_followable
  acts_as_sequenced scope: :root_id, column: :fragment
  with_collection :exports, pagination: true

  attr_writer :root
  delegate :display_name, :root_object?, :is_trashable?, to: :owner, allow_nil: true

  def expired?
    expires_at? && expires_at < Time.current
  end

  def iri(opts = {})
    RDF::URI(
      expand_uri_template("#{owner_type.constantize.model_name.route_key}_iri", iri_opts.merge(opts))
    )
  end

  def iri_opts
    {id: fragment, root_id: root.owner.url}
  end

  # @return [Array] The ids of (persisted) ancestors, excluding self
  def persisted_ancestor_ids
    parent&.persisted_edge&.path&.split('.')&.map(&:to_i)
  end

  # @return [Array] The ids of (persisted) ancestors, including self if persisted
  def self_and_ancestor_ids
    persisted_edge.path.split('.').map(&:to_i)
  end

  def shortnameable?
    %w[Forum Page].include?(owner_type)
  end

  def children_count(association)
    children_counts[association.to_s].to_i || 0
  end

  def parent_edge(type)
    return parent if type.nil?
    return self if owner_type == type.to_s.classify
    return persisted_edge&.parent_edge(type) unless persisted?
    if type == :page
      root
    elsif type == :forum
      tenant = Edge.find_by(id: self_and_ancestor_ids[1])
      tenant&.owner_type == 'Forum' ? tenant : nil
    else
      ancestors.find_by(owner_type: type.to_s.classify)
    end
  end

  def parent_model(type = nil)
    parent_edge(type)&.owner
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

  def is_child_of?(edge)
    ancestor_ids.include?(edge.id)
  end

  def is_trashed?
    @is_trashed ||= trashed_at ? trashed_at <= Time.current : false
  end
  alias is_trashed is_trashed?

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
    FollowersCollector.new(resource: owner, follow_type: level).count
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

  def self.show_trashed(show_trashed = nil)
    show_trashed ? where(nil) : untrashed
  end

  def trash
    return if trashed_at.present?
    self.class.transaction do
      update!(trashed_at: Time.current)
      owner.destroy_notifications if owner.is_loggable?
      decrement_counter_caches if is_published?
      owner.run_callbacks :trash
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
      owner.run_callbacks :untrash
    end
    true
  end

  def reload(_opts = {})
    @is_trashed = nil
    @persisted_edge = nil
    super
  end

  private

  def destroy_children
    return if owner_type == 'Page'
    children.destroy_all
  end

  def destroy_redis_children
    keys = RedisResource::Key.new(path: "#{path}.*").matched_keys.map(&:key)
    Argu::Redis.redis_instance.del(*keys) if keys.present?
  end

  def requires_location?
    owner_type == 'Motion' && parent.owner_type == 'Question' && parent.owner.require_location
  end

  def reset_persisted_edge
    @persisted_edge = nil
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
      self.root_id ||= parent.root_id
    end
  end

  def set_user_id
    self.user_id = owner.publisher.present? ? owner.publisher.id : 0
  end
end
