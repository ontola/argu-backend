# frozen_string_literal: true

module Edgeable
  module Properties
    module Serializer
      extend ActiveSupport::Concern

      class_methods do # rubocop:disable Metrics/BlockLength
        def inherited(klass)
          super

          klass.serializable_class&.defined_properties&.each do |property_options|
            if property_options[:type] == :linked_edge_id
              association_property(klass, property_options)
            elsif property_options[:enum]
              enum_property(klass, property_options)
            else
              attribute_property(klass, property_options)
            end
          end
        end

        private

        def association_property(klass, property_options) # rubocop:disable Metrics/AbcSize
          if property_options[:array]
            name = property_options[:name].to_s.chomp('_ids').pluralize
            return if klass.attributes_to_serialize.include?(name.to_sym)

            klass.has_many name, predicate: property_options[:predicate]
          else
            name = property_options[:name].to_s.chomp('_id')
            return if klass.attributes_to_serialize.include?(name.to_sym)

            klass.has_one name, predicate: property_options[:predicate]
          end
        end

        def attribute_property(klass, property_options)
          return if klass.attributes_to_serialize.include?(property_options[:name].to_sym)

          klass.attribute property_options[:name], predicate: property_options[:predicate]
        end

        def enum_property(klass, property_options)
          return if klass.attributes_to_serialize.include?(property_options[:name].to_sym)

          klass.enum property_options[:name], predicate: property_options[:predicate]
        end
      end
    end
  end
end
