# frozen_string_literal: true

module DataCube
  class ObservationSerializer < BaseSerializer
    triples :dimensions
    triples :measures

    def dimensions
      object.dimensions.map do |dimension, value|
        RDF::Statement.new(object.iri, dimension.predicate, value, graph_name: NS::LL[:supplant])
      end
    end

    def measures
      object.measures.map do |measure, value|
        RDF::Statement.new(object.iri, measure.predicate, value, graph_name: NS::LL[:supplant])
      end
    end
  end
end
