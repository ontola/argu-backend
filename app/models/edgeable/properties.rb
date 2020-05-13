# frozen_string_literal: true

module Edgeable
  module Properties
    extend ActiveSupport::Concern

    included do
      has_many :properties, primary_key: :uuid, autosave: true, dependent: :destroy

      attr_accessor :properties_preloaded
      attr_accessor :property_managers

      class_attribute :defined_properties
    end

    def preload_properties(force = false)
      return if !force && (properties_preloaded || !association_cached?(:properties))

      self.property_managers = {}

      defined_properties&.each do |p|
        property_manager(p[:predicate]).preload
        clear_attribute_change(p[:name])
      end
      self.properties_preloaded = true
    end

    def property_manager(predicate)
      property_managers[predicate] ||= Manager.new(self, predicate)
    end

    def reload(_opt = {})
      super
      preload_properties(true)
      self
    end

    private

    def assign_property(name, value)
      property_opts = self.class.property_options(name: name)
      value = [value] if property_opts[:array] && !value.is_a?(Array)
      property_manager(property_opts[:predicate]).value = value
    end

    def initialize_internals_callback
      super
      preload_properties(true)
    end

    module ClassMethods
      def property_options(filter)
        defined_properties&.detect { |property| filter.all? { |key, value| property[key] == value } }
      end

      def property?(name)
        property_options(name: name.try(:to_sym)).present?
      end

      def property_join(key)
        joins(property_join_string(key))
      end

      def property_join_string(key)
        property = property_options(name: key)
        column = "properties.#{connection.quote_string(property[:type].to_s)}"
        where = "properties.predicate = '#{connection.quote_string(property[:predicate].to_s)}'"
        select = "(SELECT DISTINCT edge_id, #{column} AS value FROM properties WHERE #{where})"
        "LEFT JOIN #{select} #{key}_filter ON #{key}_filter.edge_id = edges.uuid"
      end

      def property_filter_string(key, value)
        column = "#{key}_filter.value"
        predicate_builder.build_from_hash(column => value)[0].to_sql.gsub(/\$\d+/, '?')
      end

      private

      def define_property_setter(name)
        define_method "#{name}=" do |value|
          super(assign_property(name, value))
        end
      end

      def initialize_defined_properties
        return if defined_properties && method(:defined_properties).owner == singleton_class

        self.defined_properties = superclass.try(:defined_properties)&.dup || []
      end

      def property(name, type, predicate, opts = {})
        initialize_defined_properties
        defined_properties << {name: name, type: type, predicate: predicate}.merge(opts)

        attr_opts = {default: opts[:default]}
        attr_opts[:array] = true if opts[:array]

        attribute name, property_type(type), **attr_opts

        enum name => opts[:enum] if opts[:enum].present?

        define_property_setter(name)
      end

      def property_type(type)
        case type
        when :linked_edge_id
          :uuid
        else
          type
        end
      end
    end
  end
end

module ActiveRecord
  module Associations
    class Preloader
      class Association #:nodoc:
        private

        def associate_records_to_owner(owner, records)
          association = owner.association(reflection.name)
          association.loaded!
          if reflection.collection?
            association.target.concat(records)
          else
            association.target = records.first unless records.empty?
          end
          owner.preload_properties if reflection.name.to_sym == :properties
        end
      end
    end
  end

  class Relation
    def load(&block)
      exec_queries(&block) unless loaded?
      @records.select { |record| record.is_a?(Edge) }.each(&:preload_properties)
      @records
        .select { |record| record.respond_to?(:initialize_virtual_attributes, true) }
        .each { |record| record.send(:initialize_virtual_attributes) }
      self
    end

    def where(opts = :chain, *rest) # rubocop:disable Metrics/AbcSize
      unless klass <= Edge && opts.is_a?(Hash) && opts.present? && (properties = properties_from_opts(opts)).presence
        return super
      end

      properties.reduce(where(opts.except(*properties.keys), *rest)) do |query, condition|
        key = condition.first.to_sym
        value = property_filter_value(key, condition.second)
        query
          .joins(target_class.property_join_string(key))
          .where(target_class.property_filter_string(key, value), *(value.is_a?(Array) ? value.compact : value))
      end
    end

    def order(*args)
      return super unless klass <= Edge

      sanitize_order_args(args)
      return super if args.detect { |arg| order_property?(arg) }.nil?

      apply_order_with_properties(spawn, args)
    end

    def reorder(*args)
      return super unless klass <= Edge

      sanitize_order_args(args)
      return super if args.detect { |arg| order_property?(arg) }.nil?

      apply_order_with_properties(spawn.reorder!, args)
    end

    private

    def apply_order_with_properties(spawn, args)
      args.reduce(spawn) do |q, statement|
        order_property?(statement) ? order_by_property(q, statement) : q.order(statement)
      end
    end

    def order_by_property(query, statement)
      if statement.is_a?(Hash)
        order_key = statement.keys.first
        order_predicate = statement.values.first
      else
        order_key = statement
        order_predicate = :asc
      end
      query
        .joins(property_join_string(order_key))
        .order(arel_table.alias("#{order_key}_filter")[:value].send(order_predicate))
    end

    def order_property?(arg) # rubocop:disable Metrics/MethodLength
      return false if arg.is_a?(String)

      key =
        case arg
        when Hash
          arg.keys.first
        when Arel::Nodes::Ordering
          arg.expr.name
        else
          arg
        end
      target_class.property?(key)
    end

    def properties_from_opts(opts)
      opts.select { |key, _value| target_class.property?(key) }
    end

    def property_filter_value(key, value)
      property = property_options(name: key)
      return value if property[:enum].blank? || value.is_a?(Integer)
      return value.map { |val| property_filter_value(key, val) } if value.is_a?(Array)

      property[:enum][value&.to_sym]
    end

    def sanitize_order_args(args)
      args.map! { |attr| attr.is_a?(Hash) ? attr.map { |k, v| {k => v} } : attr }.flatten!
    end

    def target_class
      return klass unless klass == Edge && where_values_hash['owner_type'].is_a?(String)

      where_values_hash['owner_type'].constantize || klass
    end
  end
end

module EnumTypeExtensions
  def cast(value)
    return super unless value.is_a?(Array)

    value.map(&method(:cast))
  end

  def deserialize(value)
    return super unless value.is_a?(Array)

    value.map(&method(:deserialize))
  end

  def serialize(value)
    return super unless value.is_a?(Array)

    value.map(&method(:serialize))
  end

  def assert_valid_value(value)
    return super unless value.is_a?(Array)

    value.each(&method(:assert_valid_value))
  end
end
ActiveRecord::Enum::EnumType.prepend EnumTypeExtensions
