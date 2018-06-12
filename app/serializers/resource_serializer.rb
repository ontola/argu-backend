# frozen_string_literal: true

class ResourceSerializer < BaseSerializer
  attribute :type, predicate: RDF[:type]

  triples :triples

  def type
    RDF::RDFS[:Class]
  end

  delegate :triples, to: :object
end
