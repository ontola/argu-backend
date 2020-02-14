# frozen_string_literal: true

module Edgeable
  module Properties
    class Manager
      attr_accessor :instance, :predicate
      attr_reader :value

      def initialize(instance, predicate)
        self.instance = instance
        self.predicate = predicate
      end

      def preload
        @value = properties.any? ? current_value : default_value
        sync_property(@value) unless @value.nil?
      end

      def value=(val)
        return if value == val

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
        instance.properties.build(root: instance.root, edge: instance, predicate: predicate, value: value, order: order)
      end

      def current_value
        array? ? properties.map(&:value) : properties.first&.value
      end

      def default_value
        return array? ? [] : nil if options[:default].nil?

        build_property(options[:default], 0).value
      end

      def initialize_properties
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
        instance
          .properties
          .select { |prop| prop.predicate == predicate && !prop.marked_for_destruction? }
          .sort_by(&:order)
      end

      def sync_property(val)
        instance.send("#{options[:name]}=", val)
      end
    end
  end
end
