# frozen_string_literal: true

class MeasureTypeSerializer < ContentEdgeSerializer
  has_one :parent, key: :partOf, predicate: NS::SCHEMA[:isPartOf] do
    Category.root_collection
  end

  count_attribute :measures
end
