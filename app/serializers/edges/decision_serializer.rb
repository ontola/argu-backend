# frozen_string_literal: true

class DecisionSerializer < EdgeSerializer
  enum :state, predicate: NS.argu[:decisionState] do |object|
    enum_value(:state, object) if object.persisted?
  end
end
