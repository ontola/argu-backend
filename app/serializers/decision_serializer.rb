# frozen_string_literal: true

class DecisionSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :state, predicate: NS::ARGU[:decisionState]
end
