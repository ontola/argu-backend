# frozen_string_literal: true

require 'rdf/ntriples'

module ActiveModelSerializers
  module Adapter
    class N3
      class Relationship < JsonApi::Relationship
        def triples
          data = data_for(association)
          return if data.blank?
          (data.is_a?(Array) ? data : [data]).map do |relationship|
            Triple.new(
              parent_serializer.id,
              association.options[:predicate],
              RDF::IRI.new(relationship[:id])
            )
          end
        end
      end
    end
  end
end
