# frozen_string_literal: true
# Interface for the edge hierarchy.
module Edgeable
  extend ActiveSupport::Concern

  included do
    include Parentable

    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy,
            required: true
    has_many :edge_children, through: :edge, source: :children
    has_many :grants, through: :edge
    scope :published, -> { joins(edge_join_string).where("#{edge_join_alias}.is_published = true") }
    scope :unpublished, -> { joins(edge_join_string).where("#{edge_join_alias}.is_published = false") }
    scope :trashed, -> { joins(edge_join_string).where("#{edge_join_alias}.trashed_at IS NOT NULL") }
    scope :untrashed, -> { joins(edge_join_string).where("#{edge_join_alias}.trashed_at IS NULL") }
    scope :expired, -> { joins(edge_join_string).where("#{edge_join_alias}.expires_at <= ?", DateTime.current) }

    before_save :save_linked_record
    validate :validate_parent_type

    accepts_nested_attributes_for :edge
    delegate :persisted_edge, :last_activity_at, :children_count, :follows_count, :expires_at, to: :edge
    delegate :potential_audience, to: :parent_edge
    counter_cache false

    def self.edge_join_alias
      "\"edges_#{class_name}\""
    end

    def self.edge_join_string
      "INNER JOIN \"edges\" #{edge_join_alias} ON #{edge_join_alias}.\"owner_id\" = \"#{class_name}\".\"id\" "\
      "AND #{edge_join_alias}.\"owner_type\" = '#{class_name.classify}'"
    end

    def counter_cache_name
      return class_name if self.class.counter_cache_options == true
      match = self.class.counter_cache_options.find do |_, conditions|
        conditions.all? { |key, value| send("#{key}_before_type_cast") == value }
      end
      match[0].to_s
    end

    def is_edgeable?
      true
    end

    def self.is_edgeable?
      true
    end

    def is_published?
      persisted? && edge.is_published?
    end

    def root_object?
      false
    end

    def parent_edge(type = nil)
      type.nil? ? edge&.parent : edge&.parent_edge(type)
    end

    def save_linked_record
      return unless parent_model&.is_a?(LinkedRecord) && parent_model.changed?
      parent_model.save!
    end

    def save(opts = {})
      store_in_redis?(opts) ? store_in_redis : super
    end

    def save!(opts = {})
      store_in_redis?(opts) ? store_in_redis : super
    end

    def validate_parent_type
      return if edge&.parent.nil? || self.class.parent_classes.include?(edge.parent.owner_type.underscore.to_sym)
      errors.add(:parent, "#{edge.parent.owner_type} is not permitted as parent for #{class_name}")
    end

    def destroy
      remove_from_redis if store_in_redis?
      super if persisted?
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
    alias_method :pinned?, :pinned

    def pinned=(value)
      edge.pinned_at = value == '1' ? DateTime.current : nil
    end

    def store_in_redis
      RedisResource::Resource.new(resource: self).save
    end

    def reload(_opts = {})
      @parent_model = {}
      edge&.persisted_edge = nil
      super
    end

    def remove_from_redis
      RedisResource::Resource.new(resource: self).destroy
    end
  end

  module ClassMethods
    # Hands over publication of a collection to the Community profile
    def anonymize(collection)
      collection.update_all(creator_id: Profile::COMMUNITY_ID)
    end

    # @param value [Bool, Hash] True to use default counter_cache_name
    #                           Hash to use conditional counter_cache_names
    # @example counter cache for pro_arguments and con_arguments
    #   counter_cache arguments_pro: {pro: true}, arguments_con: {pro: false}
    def counter_cache(value)
      cattr_accessor :counter_cache_options do
        value
      end
    end

    def edge_includes_for_index
      {
        published_publications: {},
        custom_placements: {place: {}},
        owner: {default_cover_photo: {}}
      }
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
      options[:source_type] = options[:class_name] || name.to_s.classify
      has_many "#{name}_from_tree".to_sym, scope, options
      alias_attribute name.to_sym, "#{name}_from_tree".to_sym
    end

    # Hands over ownership of a collection to the Community user
    def expropriate(collection)
      collection.update_all(publisher_id: User::COMMUNITY_ID)
    end

    # Resets the counter_caches of the parents of all instances of this class
    # Inspired by CounterCulture#counter_culture_fix_counts
    # See {counter_cache}
    # @return [Array<Hash>]
    def fix_counts
      return unless counter_cache_options
      if counter_cache_options == true
        fix_counts_with_options
      else
        counter_cache_options.map { |options| fix_counts_with_options(*options) }.flatten
      end
    end

    def fix_counts_with_options(cache_name = nil, conditions = nil)
      fixed = []
      cache_name ||= name.tableize
      query = fix_counts_query(cache_name, conditions)
      start = 0
      batch_size = 1000
      while (records = query.offset(start).limit(batch_size).group('parents_edges.id').to_a).any?
        records.each do |model|
          count = model.read_attribute('count') || 0
          next if model.read_attribute("#{cache_name}_count") == count
          fixed << {
            entity: 'Edge',
            id: model.id,
            what: "#{cache_name}_count",
            wrong: model.send("#{cache_name}_count"),
            right: count
          }
          Edge
            .where(id: model.id)
            .update_all([%(children_counts = children_counts || hstore(?,?)), cache_name, count.to_s])
        end
        start += batch_size
      end
      fixed
    end

    def fix_counts_query(cache_name, conditions)
      query =
        Edge
          .where(owner_type: name)
          .where('edges.trashed_at IS NULL AND edges.is_published = true')
          .select('parents_edges.id, parents_edges.parent_id, COUNT(parents_edges.id) AS count, ' \
                  "CAST(COALESCE(parents_edges.children_counts -> '#{cache_name}', '0') AS integer) " \
                  "AS #{cache_name}_count")
          .joins('LEFT JOIN edges parents_edges ON parents_edges.id = edges.parent_id')
          .reorder('parents_edges.id ASC')
      return query if conditions.nil?
      query = query.joins("INNER JOIN #{name.tableize} ON #{name.tableize}.id = edges.owner_id")
      conditions.reduce(query) { |a, e| a.where("#{name.tableize}.#{e[0]} = ?", e[1]) }
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_edgeable?
          false
        end
      end
    end

    def is_edgeable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
