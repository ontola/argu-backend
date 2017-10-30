# frozen_string_literal: true

class GroupSerializer < BaseEdgeSerializer
  attribute :name, key: :displayName, predicate: 'htp://schema.org/name'

  has_one :creator, predicate: RDF::SCHEMA[:creator] do
    nil
  end
end
