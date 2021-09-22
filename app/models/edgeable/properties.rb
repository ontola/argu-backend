# frozen_string_literal: true

require 'types/iri_type'

module Edgeable
  module Properties
    extend ActiveSupport::Concern

    included do
      include Edgeable::Properties::Associations

      has_many :properties,
               primary_key: :uuid,
               autosave: true,
               dependent: :destroy
      has_many :linked_properties,
               class_name: 'Property',
               primary_key: :linked_edge_id,
               dependent: :destroy

      attr_accessor :properties_preloaded
      attr_accessor :property_managers

      class_attribute :defined_properties
    end

    def preload_properties(force = false)
      return if !force && (properties_preloaded || !association_cached?(:properties))

      self.property_managers = {}

      defined_properties&.each do |p|
        preload_property(p) unless p[:preload] == false
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

    def write_attribute(name, value)
      value = assign_property(name, value) if self.class.property_options(name: name.to_sym)

      super(name, value)
    end

    def _write_attribute(name, value)
      value = assign_property(name, value) if self.class.property_options(name: name.to_sym)

      super(name, value)
    end

    private

    def assign_property(name, value)
      property_opts = self.class.property_options(name: name.to_sym)
      value = [value] if property_opts[:array] && !value.is_a?(Array)
      property_manager(property_opts[:predicate]).value = value
    end

    def initialize_internals_callback
      super
      preload_properties(true)
    end

    def preload_property(property)
      property_manager(property[:predicate]).preload
      clear_attribute_change(property[:name])
    end

    module ClassMethods
      def association_property?(name)
        key = :"#{name}_id"
        property_options(name: key).present?
      end

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
        property = property_options(name: key.to_sym)
        column = "properties.#{connection.quote_string(property[:type].to_s)}"
        where = "properties.predicate = '#{connection.quote_string(property[:predicate].to_s)}'"
        select = "(SELECT DISTINCT edge_id, #{column} AS value FROM properties WHERE #{where})"
        "LEFT JOIN #{select} #{key}_filter ON #{key}_filter.edge_id = edges.uuid"
      end

      def property_filter_string(key, value)
        column = "#{key}_filter.value"
        predicate_builder.build_from_hash(column => value)[0].to_sql.gsub(/\$\d+/, '?')
      end

      def skipped_properties
        return @skipped_properties if instance_variables.include?(:@skipped_properties)

        @skipped_properties =
          defined_properties
            &.select { |property| property[:preload] == false }
            &.map { |property| property[:predicate].to_s }
      end

      private

      def define_property_belongs_to(foreign_key, association, opts)
        type = opts[:array] ? :has_many : :has_one
        class_name = opts[:association_class] || association.to_s.classify
        property_association(type, association, foreign_key_property: foreign_key, class_name: class_name)

        if opts[:array]
          define_property_belongs_to_many_setter(foreign_key, association, opts)
        else
          define_property_belongs_to_getter(foreign_key, association)
          define_property_belongs_to_setter(foreign_key, association, opts)
        end
      end

      def define_property_belongs_to_getter(name, association)
        define_method name do
          primary_key = association(association).reflection.active_record_primary_key
          association(association).reader.try(primary_key)
        end
      end

      def define_property_belongs_to_setter(name, association, opts)
        define_method "#{name}=" do |value|
          assign_property(name, value)
          manager = property_manager(opts[:predicate])
          super(value)
          association(association).target = manager.linked_edges.first if manager.dirty?
        end
      end

      def define_property_belongs_to_many_setter(name, association, opts)
        define_method "#{name}=" do |value|
          assign_property(name, value)
          manager = property_manager(opts[:predicate])
          send("#{name}_will_change!")
          if manager.dirty?
            association(association).target = manager.linked_edges
          else
            super(value)
          end
        end
      end

      def define_property_getter(opts)
        define_method opts[:name] do
          preload_property(opts)
          attributes[opts[:name].to_s]
        end
      end

      def initialize_defined_properties
        return if defined_properties && method(:defined_properties).owner == singleton_class

        self.defined_properties = superclass.try(:defined_properties)&.dup || []
      end

      def property(name, type, predicate, opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        initialize_defined_properties
        options = {name: name, type: type, predicate: predicate}.merge(opts)
        defined_properties << options

        attr_opts = {default: opts[:default]}
        attr_opts[:array] = true if opts[:array]

        attribute name, property_type(type), **attr_opts

        if type == :linked_edge_id
          association = opts[:association] || name.to_s.chomp('_id').to_sym
          define_property_belongs_to(name, association, options)
        else
          enum name => opts[:enum] if opts[:enum].present?
          define_property_getter(options) if opts[:preload] == false
        end
      end

      def property_type(type)
        case type
        when :linked_edge_id
          :uuid
        when :iri
          IRIType.new
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
      unless loaded?
        @records = exec_queries(&block)
        @loaded = true
      end
      @records.select { |record| record.is_a?(Edge) }.each(&:preload_properties)
      @records
        .select { |record| record.respond_to?(:initialize_virtual_attributes, true) }
        .each { |record| record.send(:initialize_virtual_attributes) }
      self
    end

    def where(*rest) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      opts = rest.first
      unless klass <= Edge && opts.is_a?(Hash) && opts.present? && (properties = properties_from_opts(opts)).presence
        return super
      end

      properties.reduce(where(opts.except(*properties.keys), *rest[1..])) do |query, condition|
        key = property_filter_key(condition.first)
        value = property_filter_value(key, condition.second)
        base = property_options(name: key)[:preload] == false ? query.joins(:properties) : query
        base
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
      opts.select { |key, _value| target_class.property?(key) || target_class.association_property?(key) }
    end

    def property_filter_key(value)
      association_key = :"#{value}_id"
      property = property_options(name: association_key)

      return value.to_sym if property.blank? || property[:type] != :linked_edge_id

      association_key
    end

    def property_filter_value(key, value)
      property = property_options(name: key)
      return value.uuid if property[:type] == :linked_edge_id && value.is_a?(Edge)
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
