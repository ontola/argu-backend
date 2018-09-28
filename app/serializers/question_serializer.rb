# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  attribute :default_motion_sorting, predicate: NS::ARGU[:defaultSorting]
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
end
