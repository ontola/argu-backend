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

        def association_property(klass, property_options)
          if property_options[:array]
            name = property_options[:name].to_s.chomp('_ids').pluralize
            klass.has_many name, predicate: property_options[:predicate]
          else
            name = property_options[:name].to_s.chomp('_id')
            klass.has_one name, predicate: property_options[:predicate]
          end
        end

        def attribute_property(klass, property_options)
          klass.attribute property_options[:name], predicate: property_options[:predicate]
        end

        def enum_property(klass, property_options)
          klass.enum property_options[:name], predicate: property_options[:predicate]
        end
      end
    end
  end
end
