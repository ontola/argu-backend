# frozen_string_literal: true

module DataCube
  class ObservationSerializer < BaseSerializer
    triples :dimensions
    triples :measures

    def dimensions
      object.dimensions.map { |dimension, value| RDF::Statement.new(object.iri, dimension.predicate, value) }
    end

    def measures
      object.measures.map { |measure, value| RDF::Statement.new(object.iri, measure.predicate, value) }
    end
  end
end
