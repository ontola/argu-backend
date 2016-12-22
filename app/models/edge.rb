
# frozen_string_literal: true
class Edge < ActiveRecord::Base
  belongs_to :owner,
             inverse_of: :edge,
             polymorphic: true,
             required: true
  belongs_to :parent,
             class_name: 'Edge',
             inverse_of: :children
  belongs_to :user,
             required: true
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id
  has_many :decisions, foreign_key: :decisionable_id, source: :decisionable, inverse_of: :decisionable
  has_many :favorites, dependent: :destroy
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy
  has_many :grants, dependent: :destroy
  has_many :groups, through: :grants
  has_many :group_memberships, through: :groups
  has_many :publications,
           foreign_key: :publishable_id,
           dependent: :destroy
  has_one :argu_publication,
          -> { where(channel: 'argu') },
          class_name: 'Publication',
          foreign_key: :publishable_id
  scope :published, -> { where('is_published = true') }
  scope :unpublished, -> { where('is_published = false') }
  scope :trashed, -> { where('trashed_at IS NOT NULL') }
  scope :untrashed, -> { where('trashed_at IS NULL') }

  accepts_nested_attributes_for :argu_publication

  validates :parent, presence: true, unless: :root_object?

  before_destroy :decrement_counter_cache, unless: :is_trashable?
  before_destroy :update_children
  before_save :set_user_id
  before_save :trash_or_untrash, if: :is_trashed_changed?

  acts_as_followable
  has_ltree_hierarchy

  attr_writer :is_trashed
  delegate :display_name, :root_object?, :is_trashable?, to: :owner

  # For Rails 5 attributes
  # The user that has created the edge's owner.
  # attribute :user, User
  # The model the edge belongs to
  # attribute :owner_id, :integer
  # attribute :owner_type, :string
  # Refers to the parent edge
  # attribute :parent_id, :integer

  def ancestor_ids
    path.split('.').map(&:to_i)
  end

  def children_count(association)
    children_counts[association.to_s].to_i || 0
  end

  def get_parent(type)
    if type == :page
      root
    elsif type == :forum
      Edge.find(ancestor_ids[1])
    else
      ancestors.find_by(owner_type: type.to_s.classify)
    end
  end

  def granted_groups(role)
    Group
      .joins(grants: :edge)
      .where(edges: {id: ancestor_ids})
      .where('grants.role >= ?', Grant.roles[role])
      .order('groups.name ASC')
      .select('groups.*, grants.role as role, grants.id as grant_id, grants.edge_id as granted_edge_id')
  end

  def granted_group_ids(role)
    granted_groups(role).pluck(:id)
  end

  def is_child_of?(edge)
    ancestor_ids.include?(edge.id)
  end

  def is_trashed?
    @is_trashed ||= trashed_at.present?
  end
  alias is_trashed is_trashed?

  def is_trashed=(value)
    value = (value == true || value == '1')
    attribute_will_change!('is_trashed') if is_trashed != value
    @is_trashed = value
  end

  def persisted_edge
    return @persisted_edge if @persisted_edge.present?
    persisted = self
    persisted = persisted.parent until persisted.parent.nil? || persisted.persisted?
    @persisted_edge = persisted if persisted.persisted?
  end

  # Only returns a value when the model has been saved
  def polymorphic_tuple
    [owner_type, owner_id]
  end

  # Calculated the number of unique followers for at least {level}
  # @param [Symbol] level The lowest type of follower to include
  # @return [Integer] The number of followers
  def potential_audience(level = :reactions)
    follows.where('follow_type >= ?', Follow.follow_types[level]).uniq.count
  end

  def publish!
    self.class.transaction do
      update!(is_published: true)
      owner.happening.update!(is_published: true) if owner.respond_to?(:happening)
      increment_counter_cache unless is_trashed?
    end
  end

  def trash
    self.class.transaction do
      update!(trashed_at: DateTime.current)
      owner.destroy_notifications if owner.is_loggable?
      decrement_counter_cache if is_published?
    end
  end

  def untrash
    self.class.transaction do
      update!(trashed_at: nil)
      increment_counter_cache if is_published?
    end
  end

  def decrement_counter_cache
    return unless owner.class.counter_cache_options
    parent.children_counts[owner.counter_cache_name] = (parent.children_counts[owner.counter_cache_name].to_i || 0) - 1
    parent.save
  end

  def increment_counter_cache
    return unless owner.class.counter_cache_options
    parent.children_counts[owner.counter_cache_name] = (parent.children_counts[owner.counter_cache_name].to_i || 0) + 1
    parent.save
  end

  private

  def set_user_id
    self.user_id = owner.publisher.present? ? owner.publisher.id : 0
  end

  def trash_or_untrash
    is_trashed? ? trash : untrash
  end

  def is_trashed_changed?
    changed.include?('is_trashed')
  end

  def update_children
    children.each do |child|
      child.update(parent: parent)
    end
  end
end
