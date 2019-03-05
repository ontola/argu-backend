# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  attribute :default_motion_sorting, predicate: NS::ARGU[:defaultSorting]
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
  attribute :children_placements, predicate: NS::ARGU[:childrenPlacements]
  count_attribute :motions

  enum :default_motion_sorting

  def children_placements
    collection_iri(object, :placements)
  end
end
