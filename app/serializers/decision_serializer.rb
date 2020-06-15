# frozen_string_literal: true

class DecisionSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  enum :state, predicate: NS::ARGU[:decisionState]
end
