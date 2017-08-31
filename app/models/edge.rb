# frozen_string_literal: true
class Edge < ApplicationRecord
  include Placeable

  belongs_to :owner,
             inverse_of: :edge,
             polymorphic: true,
             required: true,
             dependent: :destroy
  belongs_to :parent,
             class_name: 'Edge',
             inverse_of: :children
  belongs_to :user,
             required: true
  has_many :activities, foreign_key: :trackable_edge_id, inverse_of: :trackable_edge, dependent: :nullify
  has_many :recipient_activities, class_name: 'Activity', foreign_key: :recipient_edge_id, dependent: :nullify
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id
  has_many :decisions, foreign_key: :decisionable_id, source: :decisionable
  has_one :last_decision,
          -> { order(step: :desc) },
          foreign_key: :decisionable_id,
          class_name: 'Decision'
  has_one :last_published_decision,
          -> { published.order(step: :desc) },
          foreign_key: :decisionable_id,
          class_name: 'Decision'
  has_many :favorites, dependent: :destroy
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy
  has_many :grants, dependent: :destroy
  has_many :groups, through: :grants
  has_many :group_memberships, -> { active }, through: :groups
  has_many :publications,
           foreign_key: :publishable_id,
           dependent: :destroy
  has_many :published_publications,
           -> { where('publications.published_at IS NOT NULL') },
           class_name: 'Publication',
           foreign_key: :publishable_id
  has_one :argu_publication,
          -> { where(channel: 'argu') },
          class_name: 'Publication',
          foreign_key: :publishable_id
  has_one :default_vote_event_edge,
          -> { where(owner_type: 'VoteEvent') },
          foreign_key: :parent_id,
          class_name: 'Edge'
  has_one :default_vote_event,
          through: :default_vote_event_edge,
          source: :owner,
          source_type: 'VoteEvent',
          class_name: 'VoteEvent'
  # Children associations
  has_many :arguments,
           through: :children,
           source: :owner,
           source_type: 'Argument'
  has_many :active_arguments,
           lambda {
             published.untrashed.order("cast(edges_arguments.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
           },
           through: :children,
           source: :owner,
           source_type: 'Argument'
  has_many :motions,
           through: :children,
           source: :owner,
           source_type: 'Motion'
  has_many :active_motions,
           -> { published.untrashed.order(updated_at: :desc) },
           through: :children,
           source: :owner,
           source_type: 'Motion'
  has_many :votes,
           through: :children,
           source: :owner,
           source_type: 'Vote'

  scope :published, -> { where('edges.is_published = true') }
  scope :unpublished, -> { where('edges.is_published = false') }
  scope :trashed, -> { where('edges.trashed_at IS NOT NULL') }
  scope :untrashed, -> { where('edges.trashed_at IS NULL') }
  scope :expired, -> { where('edges.expires_at <= ?', DateTime.current) }

  accepts_nested_attributes_for :argu_publication

  validates :parent, presence: true, unless: :root_object?
  validates :placements, presence: true, if: :requires_location?

  before_destroy :decrement_counter_cache, unless: :is_trashed?
  before_destroy :reset_persisted_edge
  before_destroy :destroy_children
  before_destroy :destroy_redis_children
  before_save :set_user_id

  acts_as_followable
  has_ltree_hierarchy

  attr_writer :root
  delegate :display_name, :root_object?, :is_trashable?, to: :owner, allow_nil: true

  def arguments_pro
    @arguments_pro ||= active_arguments.select(&:pro?)
  end

  def arguments_con
    @arguments_con ||= active_arguments.select(&:con?)
  end

  # @return [Array] The ids of (persisted) ancestors, excluding self
  def persisted_ancestor_ids
    parent && parent.persisted_edge.path.split('.').map(&:to_i)
  end

  # @return [Array] The ids of (persisted) ancestors, including self if persisted
  def self_and_ancestor_ids
    persisted_edge.path.split('.').map(&:to_i)
  end

  # Selects edges of a certain type over persisted and transient models.
  # @param [String] type The (child) edges' #owner_type value
  # @param [Hash] where_clause Filter options for the owners of the edge akin to activerecords' `where`.
  # @option where_clause [Integer, #confirmed?] :creator :publisher If the object is not `#confirmed?`,
  #         the system will use transient resources.
  # @return [ActiveRecord::Relation, RedisResource::Relation]
  def self.where_owner(type, where_clause = {})
    if (where_clause[:creator].present? && !where_clause[:creator].confirmed?) ||
        (where_clause[:publisher].present? && !where_clause[:publisher].confirmed?)
      RedisResource::EdgeRelation.where(where_clause.merge(owner_type: type))
    else
      where_clause[:creator_id] ||= where_clause.delete(:creator).id if where_clause[:creator].present?
      where_clause[:publisher_id] ||= where_clause.delete(:publisher).id if where_clause[:publisher].present?
      table = ActiveRecord::Base.connection.quote_string(type.tableize)
      join_cond = [
        "INNER JOIN #{table} ON #{table}.id = edges.owner_id AND edges.owner_type = ?",
        type
      ]
      scope = joins(sanitize_sql_for_conditions(join_cond))
      where_clause.present? ? scope.where(type.tableize => where_clause) : scope
    end
  end

  def children_count(association)
    children_counts[association.to_s].to_i || 0
  end

  def parent_edge(type)
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

  def parent_model(type)
    parent_edge(type)&.owner
  end

  def granted_groups(role)
    Group
      .joins(grants: :edge)
      .where(edges: {id: self_and_ancestor_ids})
      .where('grants.role >= ?', Grant.roles[role])
      .order('groups.name ASC')
      .select('groups.*, grants.role as role, grants.id as grant_id, grants.edge_id as granted_edge_id')
  end

  def granted_group_ids(role)
    granted_groups(role).pluck(:id)
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

  def is_public?
    granted_groups(:member).pluck(:id).include?(-1)
  end

  def is_trashed?
    @is_trashed ||= trashed_at.present?
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
    self.class.transaction do
      update!(is_published: true)
      increment_counter_cache unless is_trashed?
    end
  end

  def root
    @root ||= super
  end

  def root_id
    @root_id ||= path.split('.').first.to_i
  end

  def trash
    return if trashed_at.present?
    self.class.transaction do
      update!(trashed_at: DateTime.current)
      owner.destroy_notifications if owner.is_loggable?
      decrement_counter_cache if is_published?
    end
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
      increment_counter_cache if is_published?
    end
  end

  def decrement_counter_cache(counter_cache_name = nil)
    return unless owner&.class&.counter_cache_options
    counter_cache_name ||= owner.counter_cache_name
    parent.children_counts[counter_cache_name] = (parent.children_counts[counter_cache_name].to_i || 0) - 1
    parent.save
  end

  def increment_counter_cache(counter_cache_name = nil)
    return unless owner.class.counter_cache_options
    counter_cache_name ||= owner.counter_cache_name
    parent.children_counts[counter_cache_name] = (parent.children_counts[counter_cache_name].to_i || 0) + 1
    parent.save
  end

  def self.path_array(paths)
    return 'NULL' if paths.blank?
    paths = case paths
            when String
              [paths]
            when ActiveRecord::Associations::CollectionProxy, ActiveRecord::Relation
              paths.map(&:path)
            else
              paths
            end
    paths.each { |path| paths.delete_if { |p| p.match(/^#{path}\./) } }
    "ARRAY[#{paths.map { |path| "'#{path}.*'::lquery" }.join(',')}]"
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

  def set_user_id
    self.user_id = owner.publisher.present? ? owner.publisher.id : 0
  end
end
