# frozen_string_literal: true

class InterventionTypeSerializer < ContentEdgeSerializer
  attribute :one_off_costs_score, predicate: NS::RIVM[:oneOffCostsScore]
  attribute :recurring_costs_score, predicate: NS::RIVM[:recurringCostsScore]
  attribute :security_improved_score, predicate: NS::RIVM[:securityImprovedScore]

  count_attribute :interventions
end
