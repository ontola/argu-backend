# frozen_string_literal: true
# Interface for the edge hierarchy.
module Edgeable
  extend ActiveSupport::Concern

  included do
    has_one :edge,
            as: :owner,
            inverse_of: :owner,
            dependent: :destroy,
            required: true
    has_many :grants, through: :edge
    scope :published, -> { joins(:edge).where('edges.is_published = true') }
    scope :unpublished, -> { joins(:edge).where('edges.is_published = false') }
    scope :trashed, -> { joins(:edge).where('edges.trashed_at IS NOT NULL') }
    scope :untrashed, -> { joins(:edge).where('edges.trashed_at IS NULL') }

    accepts_nested_attributes_for :edge
    delegate :persisted_edge, :last_activity_at, :children_count, :follows_count, to: :edge
    counter_cache false

    def counter_cache_name
      return class_name if self.class.counter_cache_options == true
      match = self.class.counter_cache_options.find do |_, conditions|
        conditions.all? { |key, value| send("#{key}_before_type_cast") == value }
      end
      match[0].to_s
    end

    def is_published?
      persisted? && edge.is_published?
    end

    def root_object?
      false
    end

    def parent_edge(type = nil)
      type.nil? ? edge.parent : edge.get_parent(type)
    end

    def parent_model(type = nil)
      parent_edge(type)&.owner
    end

    def pinned
      edge.pinned_at.present?
    end
    alias_method :pinned?, :pinned

    def pinned=(value)
      edge.pinned_at = value == '1' ? DateTime.current : nil
    end
  end

  module ClassMethods
    # @param value [Bool, Hash] True to use default counter_cache_name
    #                           Hash to use conditional counter_cache_names
    # @example counter cache for pro_arguments and con_arguments
    #   counter_cache arguments_pro: {pro: true}, arguments_con: {pro: false}
    def counter_cache(value)
      cattr_accessor :counter_cache_options do
        value
      end
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
end
