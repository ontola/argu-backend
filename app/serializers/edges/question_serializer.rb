# frozen_string_literal: true

class QuestionSerializer < DiscussionSerializer
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
  attribute :upvote_only, predicate: NS::ARGU[:upvoteOnly]
  attribute :map_question, predicate: NS::ARGU[:mapQuestion]
  count_attribute :motions

  enum :default_motion_sorting, predicate: NS::ARGU[:defaultSorting]
end
