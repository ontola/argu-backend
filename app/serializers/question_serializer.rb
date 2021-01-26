# frozen_string_literal: true

class QuestionSerializer < DiscussionSerializer
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
  attribute :map_question, predicate: NS::ARGU[:mapQuestion]
  count_attribute :motions

  enum :default_motion_sorting, predicate: NS::ARGU[:defaultSorting]
end
