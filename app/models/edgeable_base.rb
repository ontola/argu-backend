# frozen_string_literal: true

class EdgeableBase < ApplicationRecord
  self.abstract_class = true
  concern Actionable
  include Edgeable::CounterCache
  include Parentable
  include Ldable
  include Convertible
  define_model_callbacks :trash, only: :after
  define_model_callbacks :untrash, only: :after

  has_one :edge,
          as: :owner,
          inverse_of: :owner,
          dependent: :destroy,
          required: true
  belongs_to :root, class_name: 'Edge', primary_key: :uuid
  has_many :edge_children, through: :edge, source: :children
  has_many :grants, through: :edge
  scope :published, lambda {
    joins(edge_join_string).where("#{connection.quote_table_name("edges_#{class_name}")}.is_published = true")
  }
  scope :unpublished, lambda {
    joins(edge_join_string).where("#{connection.quote_table_name("edges_#{class_name}")}.is_published = false")
  }
  scope :trashed, lambda {
    joins(edge_join_string).where("#{connection.quote_table_name("edges_#{class_name}")}.trashed_at IS NOT NULL")
  }
  scope :untrashed, lambda {
    joins(edge_join_string).where("#{connection.quote_table_name("edges_#{class_name}")}.trashed_at IS NULL")
  }
  scope :expired, lambda {
    joins(edge_join_string)
      .where("#{connection.quote_table_name("edges_#{class_name}")}.expires_at <= ?", Time.current)
  }

  validate :validate_parent_type

  accepts_nested_attributes_for :edge
  delegate :persisted_edge, :last_activity_at, :children_count, :follows_count, :expires_at,
           :confirmed_before_type_cast, to: :edge
  delegate :potential_audience, to: :parent_edge

  def canonical_iri(only_path: false)
    RDF::URI(expand_uri_template(:edges_iri, id: edge.uuid, only_path: only_path))
  end

  def destroy
    remove_from_redis if store_in_redis?
    persisted? ? super : true
  end

  def iri_opts
    super.merge(
      id: edge.fragment,
      root_id: edge.root.url
    )
  end

  def is_published?
    persisted? && edge.is_published?
  end

  def move_to(new_parent)
    self.class.transaction do
      (self.class.columns.map(&:name) & %w[question_id page_id]).each do |column|
        send("#{column}=", new_parent.owner_type == column[0...-3].classify ? new_parent.owner_id : nil)
      end
      if self.class.columns.map(&:name).include?('forum_id') && new_parent.parent_model(:forum) != forum
        move_update_forum(new_parent)
      end
      yield if block_given?
      edge.parent = new_parent
      self.root_id = new_parent.root_id
      edge.root_id = new_parent.root_id
      edge.descendants.pluck('distinct owner_type').each do |klass|
        klass.constantize.joins(:edge).where('edges.path <@ ?', edge.path).update_all(root_id: root_id)
      end
      save!
    end
    true
  end

  def parent_edge(type = nil)
    type.nil? ? edge&.parent : edge&.parent_edge(type)
  end

  def parent_iri(opts = {})
    parent_model&.iri(opts)
  end

  def root_object?
    false
  end

  def save(opts = {})
    store_in_redis?(opts) ? store_in_redis : super
  end

  def save!(opts = {})
    store_in_redis?(opts) ? store_in_redis : super
  end

  # Makes sure that when included on models, the rails path helpers etc. use the object's shortname.
  # If it hasn't got a shortname, it will fall back to its id.
  # @return [String, Integer] The shortname of the model, or its id if not present.
  def to_param
    url.to_s.presence || super
  end

  # @return [String, nil] The shortname of the model or nil
  def url
    @url || edge&.shortname&.shortname
  end

  def url=(value)
    return if value == url
    root_id = is_a?(Page) ? nil : edge.root_id
    existing = Shortname.find_by(shortname: value, root_id: root_id)
    if existing&.primary?
      errors.add(:url, :taken)
      return
    end
    existing.primary = true if existing
    edge.shortnames << (existing || Shortname.new(shortname: value, root_id: root_id))
    @url = value
  end

  def parent_model(type = nil)
    @parent_model ||= {}
    @parent_model[type] ||= parent_edge(type)&.owner
  end

  def parent_model=(record, type = nil)
    @parent_model ||= {}
    @parent_model[type] ||= record
  end

  def pinned
    edge.pinned_at.present?
  end
  alias pinned? pinned

  def pinned=(value)
    edge.pinned_at = value == '1' ? Time.current : nil
  end

  def reload(_opts = {})
    @parent_model = {}
    edge&.persisted_edge = nil
    super
  end

  private

  def move_update_forum(new_parent)
    self.forum = new_parent.parent_model(:forum).lock!
    edge.descendants.lock(true).includes(:owner).find_each do |descendant|
      descendant.owner.update_column(:forum_id, forum.id)
    end
    activities
      .lock(true)
      .update_all(forum_id: forum.id, recipient_id: new_parent.owner_id, recipient_type: new_parent.owner_type)
  end

  def remove_from_redis
    RedisResource::Resource.new(resource: self).destroy
  end

  def store_in_redis
    RedisResource::Resource.new(resource: self).save
  end

  def validate_parent_type
    return if edge&.parent.nil? || self.class.parent_classes.include?(edge.parent.owner_type.underscore.to_sym)
    errors.add(:parent, "#{edge.parent.owner_type} is not permitted as parent for #{class_name}")
  end

  class << self
    include UUIDHelper

    # Hands over publication of a collection to the Community profile
    def anonymize(collection)
      collection.update_all(creator_id: Profile::COMMUNITY_ID)
    end

    def edge_includes_for_index
      {
        published_publications: {},
        custom_placements: {place: {}},
        owner: {default_cover_photo: {}}
      }
    end

    # Hands over ownership of a collection to the Community user
    def expropriate(collection)
      collection.update_all(publisher_id: User::COMMUNITY_ID)
    end

    # Finds an object via its shortname, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname!(url, root_id = nil)
      find_via_shortname(url, root_id) || raise(ActiveRecord::RecordNotFound)
    end

    # Finds an object via its shortname, returns nil when not found
    def find_via_shortname(url, root_id = nil)
      if root_id && !uuid?(root_id)
        root_id = Page.find_via_shortname(root_id)&.edge&.uuid
        return if root_id.blank?
      end
      joins(edge: :shortnames).where(shortnames: {root_id: root_id}).find_by('lower(shortname) = lower(?)', url)
    end

    # Finds an object via its shortname or id
    def find_via_shortname_or_id(url, root_id = nil)
      if (/[a-zA-Z]/i =~ url).nil?
        joins(:edge).find_by(id: url, edges: {root_id: root_id})
      else
        find_via_shortname(url, root_id)
      end
    end

    # Finds an object via its shortname or id, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname_or_id!(url, root_id = nil)
      find_via_shortname_or_id(url, root_id) || raise(ActiveRecord::RecordNotFound)
    end

    private

    def edge_join_alias
      connection.quote_table_name("edges_#{class_name}")
    end

    def edge_join_string
      "INNER JOIN \"edges\" #{edge_join_alias} ON #{edge_join_alias}.\"owner_id\" = #{quoted_table_name}.\"id\" "\
      "AND #{edge_join_alias}.\"owner_type\" = '#{base_class.name}'"
    end

    # Adds an association for children through the edge tree
    # Usage is the same as regular has_many
    # @note The official relation name is suffixed with '_from_tree', to prevent join naming conflicts.
    #       An alias with the original given name is added as well
    # @example edge_tree_has_many :arguments
    #   has_many :arguments_from_tree, through: :edge_children, source: :owner, source_type: 'Argument'
    #   alias :arguments, :arguments_from_tree
    #   arguments # => [ActiveRecord::Associations::CollectionProxy<Arguments>]
    def edge_tree_has_many(name, scope = nil, options = {})
      options[:through] = :edge_children
      options[:source] = :owner
      options[:source_type] ||= options[:class_name] || name.to_s.classify
      has_many "#{name}_from_tree".to_sym, scope, options
      alias_attribute name.to_sym, "#{name}_from_tree".to_sym
    end

    def with_collection(name, options = {})
      klass = options[:association_class] || name.to_s.classify.constantize
      if klass < EdgeableBase
        options[:includes] ||= {
          creator: {profileable: :shortname},
          edge: [:default_vote_event, parent: :owner]
        }
        options[:includes][:default_cover_photo] = {} if klass.reflect_on_association(:default_cover_photo)
        options[:collection_class] = EdgeableCollection
      end
      super
    end
  end
end
