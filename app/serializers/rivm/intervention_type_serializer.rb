# frozen_string_literal: true

class InterventionTypeSerializer < ContentEdgeSerializer
  has_one :parent, key: :partOf, predicate: NS::SCHEMA[:isPartOf] do
    Dashboard.find_via_shortname('maatregelen')
  end
end
