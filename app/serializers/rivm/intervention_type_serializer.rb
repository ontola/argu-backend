# frozen_string_literal: true

class InterventionTypeSerializer < ContentEdgeSerializer
  attribute :one_off_costs_score, predicate: NS::RIVM[:oneOffCostsScore] do |object|
    object.one_off_costs_score.to_f / 100
  end
  attribute :recurring_costs_score, predicate: NS::RIVM[:recurringCostsScore] do |object|
    object.recurring_costs_score.to_f / 100
  end
  attribute :security_improved_score, predicate: NS::RIVM[:securityImprovedScore] do |object|
    object.security_improved_score.to_f / 100
  end

  count_attribute :interventions
end
