# frozen_string_literal: true

module Edgeable
  module Properties
    class Manager
      attr_accessor :dirty, :instance, :is_default, :predicate
      attr_reader :value

      alias dirty? dirty

      def initialize(instance, predicate)
        self.dirty = false
        self.instance = instance
        self.predicate = predicate
      end

      def build_default_property
        build_property(options[:default], 0) if is_default
      end

      def linked_edges
        properties.map(&:linked_edge)
      end

      def preload(new_record: false)
        @value = !new_record && cached_properties.present? ? current_value : default_value
        sync_property(@value) unless @value.nil?
      end

      def value=(val)
        return if value == val

        self.dirty = true
        @value = val
        invalidate_properties
        initialize_properties
        sync_property(@value)
      end

      private

      def array?
        options[:array]
      end

      def build_property(value, order)
        root = instance.is_a?(Page) ? instance.root : ActsAsTenant.current_tenant || instance.root
        instance.properties.build(
          root: root,
          edge: instance,
          predicate: predicate,
          value: value,
          order: order
        )
      end

      def cached_properties
        return unless instance.attributes.include?('cached_properties')

        instance.cached_properties[predicate.to_s]
      end

      def current_value
        array? ? cached_properties : cached_properties.first
      end

      def default_value
        return array? ? [] : nil if options[:default].nil?

        self.is_default = true

        options[:default]
      end

      def initialize_properties
        self.is_default = false

        (value.is_a?(Array) ? value : [value]).map.with_index do |val, ind|
          build_property(val, ind)
        end
      end

      def invalidate_properties
        properties.each(&:mark_for_destruction)
      end

      def options
        @options ||= instance.class.property_options(predicate: predicate)
      end

      def properties
        options[:preload] == false ? properties_without_preload : properties_with_preload
      end

      def properties_with_preload
        instance
          .properties
          .select { |prop| prop.predicate == predicate && !prop.marked_for_destruction? }
          .sort_by(&:order)
      end

      def properties_without_preload
        @properties_without_preload ||=
          instance
            .properties
            .where(predicate: predicate.to_s)
            .sort_by(&:order)
      end

      def sync_property(val)
        instance.send("#{options[:name]}=", val)
      end
    end
  end
end
