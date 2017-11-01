# frozen_string_literal: true

class GroupSerializer < BaseEdgeSerializer
  has_one :creator, predicate: RDF::SCHEMA[:creator] do
    nil
  end
end
