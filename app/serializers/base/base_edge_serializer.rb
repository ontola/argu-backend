# frozen_string_literal: true

class BaseEdgeSerializer < RecordSerializer
  include Actionable::Serializer
  has_one :parent_model, key: :parent, predicate: NS::SCHEMA[:isPartOf]
  has_one :organization, predicate: NS::SCHEMA[:organization] do
    object.parent_model(:page)
  end
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.profileable
  end
end
