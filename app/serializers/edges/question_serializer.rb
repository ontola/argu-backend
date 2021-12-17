# frozen_string_literal: true

class QuestionSerializer < DiscussionSerializer
  has_one :location_query,
          predicate: NS.argu[:locationQuery],
          unless: method(:export_scope?)

  count_attribute :motions
end
