# frozen_string_literal: true

class BaseEdgeSerializer < RecordSerializer
  has_one :parent_model, key: :parent, predicate: RDF::SCHEMA[:isPartOf]
  has_one :organization, predicate: RDF::SCHEMA[:organization] do
    object.parent_model(:page)
  end
  has_one :creator, predicate: RDF::SCHEMA[:creator] do
    object.creator.profileable
  end
end
