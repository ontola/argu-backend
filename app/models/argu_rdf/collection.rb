# frozen_string_literal: true

module ArguRDF
  class Collection < Base
    include ::Collection::Mixin

    attr_accessor :resource,
                  :order,
                  :predicate

    def initialize(iri = nil, attributes = [], **opts)
      @iri = iri
      @id = opts[:id]
      @predicate = opts[:predicate]
      @order = opts[:order]
      @attributes = attributes
      @type = @attributes.find { |_, p, __| p == RDF.type } if @attributes
      super(**opts)
    end

    def members
      return if include_pages? || filter?
      @members ||= association_base
    end

    def serializer_class
      RDFCollectionSerializer
    end

    def type
      'collections'
    end

    def uri(query_values = '')
      base = if url_constructor.present?
               send(url_constructor, parent.id, protocol: :https)
             else
               url_for([parent, association_class, protocol: :https])
             end
      [base, query_values.to_param].reject(&:empty?).join('?')
    end

    private

    def association_base
      parent.attributes_in_resource predicate
    end

    def filter?
      false
    end
  end
end
