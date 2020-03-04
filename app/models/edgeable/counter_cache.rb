# frozen_string_literal: true

module Edgeable
  module CounterCache
    extend ActiveSupport::Concern

    included do
      before_destroy :decrement_counter_caches, unless: :is_trashed?
      after_trash :decrement_counter_caches, if: :is_published?
      after_untrash :increment_counter_caches, if: :is_published?
    end

    def reload_children_counts
      self.children_counts = Edge.unscoped.where(id: id).pluck('children_counts').first
    end

    private

    def counter_cache_names
      return [class_name] if self.class.counter_cache_options == true

      matches = self.class.counter_cache_options.select do |_, conditions|
        conditions.all? { |key, value| send("#{key}_before_type_cast") == value }
      end
      matches.map { |name, _options| name.to_s }
    end

    def decrement_counter_caches # rubocop:disable Metrics/AbcSize
      return unless self.class.class_variable_defined?(:@@counter_cache_options) && parent.present?

      parent.reload_children_counts
      counter_cache_names.each do |counter_cache_name|
        parent.children_counts[counter_cache_name] = parent.children_count(counter_cache_name) - 1
      end
      parent.save(touch: false)
    end

    def increment_counter_caches # rubocop:disable Metrics/AbcSize
      return unless self.class.class_variable_defined?(:@@counter_cache_options) && parent.present?

      parent.reload_children_counts
      counter_cache_names.each do |counter_cache_name|
        parent.children_counts[counter_cache_name] = parent.children_count(counter_cache_name) + 1
      end
      parent.save(touch: false)
    end

    module ClassMethods
      # Resets the counter_caches of the parents of all instances of this class
      # Inspired by CounterCulture#counter_culture_fix_counts
      # See {counter_cache}
      # @return [Array<Hash>]
      def fix_counts
        return unless class_variable_defined?(:@@counter_cache_options)

        if counter_cache_options == true
          fix_counts_with_options
        else
          counter_cache_options.map { |options| fix_counts_with_options(*options) }.flatten
        end
      end

      private

      # @param value [Bool, Hash] True to use default counter_cache_name
      #                           Hash to use conditional counter_cache_names
      # @example counter cache for pro_arguments and con_arguments
      #   counter_cache arguments_pro: {pro: true}, arguments_con: {pro: false}
      def counter_cache(value)
        cattr_accessor :counter_cache_options do
          value
        end
      end

      def fix_counts_query(cache_name, conditions) # rubocop:disable Metrics/AbcSize
        conditions = conditions.dup
        query =
          unscoped
            .untrashed
            .published
            .joins(:parent)
            .select('parents_edges.id, parents_edges.parent_id, COUNT(parents_edges.id) AS count, ' \
                    "CAST(COALESCE(parents_edges.children_counts -> '#{connection.quote_string(cache_name.to_s)}', "\
                    "'0') AS integer) AS #{connection.quote_string(cache_name.to_s)}_count")
            .reorder('parents_edges.id ASC')
        return query if conditions.nil?

        query.where(conditions)
      end

      def fix_counts_with_options(cache_name = nil, conditions = nil) # rubocop:disable Metrics/AbcSize
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
            edge = Edge.find(model.id)
            edge.children_counts[cache_name] = count
            edge.save(touch: false)
          end
          start += batch_size
        end
        fixed
      end
    end
  end
end
