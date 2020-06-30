# frozen_string_literal: true

class DecisionSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  enum :state, predicate: NS::ARGU[:decisionState] do |object|
    enum_value(:state, object) if object.persisted?
  end
end
