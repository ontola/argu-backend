# frozen_string_literal: true

module ArguRDF
  # Implements low-level API's to mimic ActiveModel and other required
  #   interfaces.
  class Base
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers
    include Ldable

    attr_accessor :attributes, :id, :iri, :type
    def read_attribute_for_serialization(name)
      attr = send(name)
      attr.is_a?(Array) ? attr.map(&method(:attribute_for_serialization)) : plain_attribute(attr)
    end

    def context_id
      plain_attribute(@iri)
    end

    def context_type
      plain_attribute(type)
    end

    def empty?
      false
    end

    def jsonld_context
      {}
    end

    def method_missing(name, *args, &block)
      attr = attribute_in_resource?(name)
      return attr[2] if attr.present?
      super unless name.to_s.include?('=')
    end

    def respond_to?(name, include_private = false)
      return true if attribute_in_resource?(name)
      return super unless name.to_s.include?('=')
      true
    end

    def respond_to_missing?(name, include_private = false)
      attr = attribute_in_resource?(name)
      return attr[2] if attr.present?
      return true unless name.to_s.include?('=')
      super
    end

    def serializer_class
      RDFResourceSerializer
    end

    def to_hash
      context = {}
      attrs = attributes.flat_map do |_, p, o|
        a = "attr-#{p.hash}"
        context[a] = p.to_s
        [a, o.to_s]
      end
      attrs.push('@context', context)
      Hash[*attrs]
    end

    def to_param
      id
    end

    protected

    def attribute_in_resource?(attr)
      @attributes.find { |_, p, __| p == attr }
    end

    def attributes_in_resource(attr)
      @attributes.select { |_, p, __| p == attr }
    end

    private

    def attribute_for_serialization(attr)
      obj = attr.is_a?(Array) ? attr[2] : attr
      return obj unless obj.is_a?(RDF::URI)
      {
        id: obj.to_s,
        type: ''
      }
    end

    def plain_attribute(attr)
      inner = attr.is_a?(Array) ? attr[2] : attr
      inner.is_a?(RDF::Term) ? inner.to_s : inner
    end

    def object_to_json_api(obj)
      return {id: obj.to_s, type: 'unknown'} if obj.is_a?(RDF::URI)
      obj.to_s
    end
  end
end
