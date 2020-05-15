# frozen_string_literal: true

class MeasureTypeSerializer < ContentEdgeSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf] do
    Category.root_collection
  end

  count_attribute :measures
end
