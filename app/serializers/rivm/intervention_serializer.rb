# frozen_string_literal: true

class InterventionSerializer < ContentEdgeSerializer
  extend URITemplateHelper

  attribute :communicate_action, predicate: NS.argu[:communicateAction] do |object|
    new_iri(object, :direct_messages) if object.contact_allowed?
  end
  attribute :effects, predicate: NS.rivm[:interventionEffects]
  attribute :public_organization_name, predicate: NS.rivm[:organizationName]
  attribute :one_off_costs_score, predicate: NS.rivm[:oneOffCostsScore] do |object|
    Intervention.one_off_costs[object.one_off_costs]
  end
  attribute :recurring_costs_score, predicate: NS.rivm[:recurringCostsScore] do |object|
    Intervention.recurring_costs[object.recurring_costs]
  end
  attribute :security_improved_score, predicate: NS.rivm[:securityImprovedScore] do |object|
    unless object.security_improved == 'unkown_security_improvement'
      Intervention.security_improveds[object.security_improved]
    end
  end
end
