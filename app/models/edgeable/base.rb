# frozen_string_literal: true

module Edgeable
  class Base < ApplicationRecord
    self.abstract_class = true
    include Parentable
    include Ldable

    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy,
            required: true
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
    delegate :persisted_edge, :last_activity_at, :children_count, :follows_count, :expires_at, to: :edge
    delegate :potential_audience, to: :parent_edge

    def canonical_iri(only_path: false)
      RDF::URI(expand_uri_template(:edges_iri, id: edge.uuid, only_path: only_path))
    end

    def counter_cache_names
      return [class_name] if self.class.counter_cache_options == true
      matches = self.class.counter_cache_options.select do |_, conditions|
        conditions.except(:sql).all? do |key, value|
          if value.is_a?(Symbol)
            send("#{key}_before_type_cast").send(value)
          else
            send("#{key}_before_type_cast") == value
          end
        end
      end
      matches.map { |name, _options| name.to_s }
    end

    def destroy
      remove_from_redis if store_in_redis?
      persisted? ? super : true
    end

    def iri_opts
      super.merge(
        parent_iri: parent_iri(only_path: true),
        :"#{parent_edge.owner_type.underscore}_id" => parent_edge.owner_id
      )
    end

    def is_published?
      persisted? && edge.is_published?
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

      private

      cattr_accessor :counter_cache_options do
        false
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

      def edge_join_alias
        connection.quote_table_name("edges_#{class_name}")
      end

      def edge_join_string
        "INNER JOIN \"edges\" #{edge_join_alias} ON #{edge_join_alias}.\"owner_id\" = #{quoted_table_name}.\"id\" "\
        "AND #{edge_join_alias}.\"owner_type\" = '#{class_name.classify}'"
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

      def fix_counts_query(cache_name, conditions)
        query =
          Edge
            .where(owner_type: name)
            .where('edges.trashed_at IS NULL AND edges.is_published = true')
            .select('parents_edges.id, parents_edges.parent_id, COUNT(parents_edges.id) AS count, ' \
                    "CAST(COALESCE(parents_edges.children_counts -> '#{connection.quote_string(cache_name.to_s)}', "\
                    "'0') AS integer) AS #{connection.quote_string(cache_name.to_s)}_count")
            .joins('LEFT JOIN edges parents_edges ON parents_edges.id = edges.parent_id')
            .reorder('parents_edges.id ASC')
        return query if conditions.nil?
        query = query.joins("INNER JOIN #{quoted_table_name} ON #{quoted_table_name}.id = edges.owner_id")
        if conditions.key?(:sql)
          query.where(conditions[:sql])
        else
          conditions.reduce(query) { |a, e| a.where(quoted_table_name => {e[0] => e[1]}) }
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

      def with_collection(name, options = {})
        klass = options[:association_class] || name.to_s.classify.constantize
        if klass < Edgeable::Base
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
end
