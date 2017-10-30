# frozen_string_literal: true

module ActiveModelSerializers
  module Adapter
    class N3 < JsonApi
      extend ActiveSupport::Autoload
      autoload :Relationship
      autoload :Triple

      delegate :object, to: :serializer

      def triples
        triples_for_serialization.flatten.map(&:to_s).join
      end

      private

      def triples_for_serialization
        is_collection = serializer.respond_to?(:each)
        serializers = is_collection ? serializer : [serializer]
        triples = resource_objects_for(serializers)
        triples.concat(instance_options[:meta]) if instance_options[:meta]
        triples
      end

      def attributes_for(serializer, fields)
        serializer.class._attributes_data.map do |key, data|
          next if data.excluded?(serializer)
          next unless fields.nil? || fields.include?(key)
          predicate = data.options[:predicate]
          value = serializer.attributes[key]
          next unless predicate && value
          if data.options[:inverted]
            Triple.new(value, predicate, serializer.id)
          else
            Triple.new(serializer.id, predicate, value)
          end
        end
      end

      def resource_object_for(serializer, include_slice = {})
        data_for(serializer, include_slice).concat(links_for(serializer))
      end

      def data_for(serializer, include_slice)
        data = serializer.fetch(self) do
          resource_object = serializer.id
          break nil if resource_object.nil?

          requested_fields = @fieldset && @fieldset.fields_for(type_for(serializer, instance_options).to_s)

          attributes_for(serializer, requested_fields)
        end
        data.tap do |resource_object|
          next if resource_object.nil?
          # NOTE(BF): the attributes are cached above, separately from the relationships, below.
          requested_associations = @fieldset.fields_for(type_for(serializer, instance_options).to_s) || '*'
          relationships = relationships_for(serializer, requested_associations, include_slice)
          resource_object.concat(relationships) if relationships.any?
        end
      end

      def relationships_for(serializer, requested_associations, include_slice)
        include_directive = JSONAPI::IncludeDirective.new(
          requested_associations,
          allow_wildcard: true
        )
        serializer.associations(include_directive, include_slice).map do |association|
          Relationship.new(serializer, instance_options, association).triples
        end.flatten
      end

      def links_for(serializer)
        serializer._links.map do |_key, value|
          options = Link.new(serializer, value).as_json
          next unless options.is_a?(Hash) && options.dig(:meta, :predicate)
          Triple.new(serializer.id, options[:meta][:predicate], options[:href])
        end
      end

      def type_for(serializer, instance_options)
        ResourceIdentifier.new(serializer, instance_options).as_json[:type]
      end
    end
  end
end
