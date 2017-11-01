# frozen_string_literal: true

class DecisionSerializer < BaseEdgeSerializer
  attribute :content, predicate: RDF::SCHEMA[:text]
end
