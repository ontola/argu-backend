# frozen_string_literal: true

class InterventionSerializer < ContentEdgeSerializer
  extend UriTemplateHelper

  attribute :communicate_action, predicate: NS::ARGU[:communicateAction] do |object|
    new_iri(object, :direct_messages) if object.contact_allowed?
  end
  attribute :effects, predicate: NS::RIVM[:interventionEffects]
  attribute :public_organization_name, predicate: NS::RIVM[:organizationName]
  attribute :one_off_costs_score, predicate: NS::RIVM[:oneOffCostsScore] do |object|
    Intervention.one_off_costs[object.one_off_costs]
  end
  attribute :recurring_costs_score, predicate: NS::RIVM[:recurringCostsScore] do |object|
    Intervention.recurring_costs[object.recurring_costs]
  end
  attribute :security_improved_score, predicate: NS::RIVM[:securityImprovedScore] do |object|
    unless object.security_improved == 'unkown_security_improvement'
      Intervention.security_improveds[object.security_improved]
    end
  end
end
