# frozen_string_literal: true

module DataCube
  class ObservationSerializer < BaseSerializer
    statements :dimensions
    statements :measures

    def self.dimensions(object, _params)
      object.dimensions.map do |dimension, value|
        RDF::Statement.new(object.iri, dimension.predicate, value, graph_name: NS.ld[:supplant])
      end
    end

    def self.measures(object, _params)
      object.measures.map do |measure, value|
        RDF::Statement.new(object.iri, measure.predicate, value, graph_name: NS.ld[:supplant])
      end
    end
  end
end
