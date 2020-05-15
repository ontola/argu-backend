# frozen_string_literal: true

class QuestionSerializer < DiscussionSerializer
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
  count_attribute :motions

  enum :default_motion_sorting, predicate: NS::ARGU[:defaultSorting]
end
