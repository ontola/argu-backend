# frozen_string_literal: true

class InterventionSerializer < ContentEdgeSerializer
  extend UriTemplateHelper

  attribute :additional_introduction_information, predicate: NS::RIVM[:additionalIntroductionInformation]
  attribute :communicate_action, predicate: NS::ARGU[:communicateAction] do |object|
    new_iri(object, :direct_messages) if object.contact_allowed?
  end
  attribute :cost_explanation, predicate: NS::RIVM[:costExplanation]
  attribute :effects, predicate: NS::RIVM[:interventionEffects]
  attribute :goal, predicate: NS::RIVM[:interventionGoal]
  attribute :job_title, predicate: NS::SCHEMA[:roleName]
  attribute :organization_name, predicate: NS::ARGU[:organizationName]
  attribute :public_organization_name, predicate: NS::RIVM[:organizationName]
  attribute :security_improvement_reason, predicate: NS::RIVM[:securityImprovementReason]
  attribute :show_organization_name, predicate: NS::ARGU[:showOrganizationName]
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

  enum :industry, predicate: NS::SCHEMA[:industry]
  enum :plans_and_procedure, predicate: NS::RIVM[:plansAndProcedure]
  enum :people_and_resources, predicate: NS::RIVM[:peopleAndResources]
  enum :competence, predicate: NS::RIVM[:competence]
  enum :communication, predicate: NS::RIVM[:communication]
  enum :motivation_and_commitment, predicate: NS::RIVM[:motivationAndCommitment]
  enum :conflict_and_prioritization, predicate: NS::RIVM[:conflictAndPrioritization]
  enum :ergonomics, predicate: NS::RIVM[:ergonomics]
  enum :tools, predicate: NS::RIVM[:tools]
  enum :target_audience, predicate: NS::RIVM[:targetAudience]
  enum :risk_reduction, predicate: NS::RIVM[:riskReduction]
  enum :continuous, predicate: NS::RIVM[:continuous]
  enum :independent, predicate: NS::RIVM[:independent]
  enum :management_involvement, predicate: NS::RIVM[:managementInvolvement]
  enum :training_required, predicate: NS::RIVM[:trainingRequired]
  enum :nature_of_costs, predicate: NS::RIVM[:natureOfCosts]
  enum :one_off_costs, predicate: NS::RIVM[:oneOffCosts]
  enum :recurring_costs, predicate: NS::RIVM[:recurringCosts]
  enum :effectivity_research_method, predicate: NS::RIVM[:effectivityResearchMethod]
  enum :security_improved, predicate: NS::RIVM[:securityImproved]
  enum :business_section, predicate: NS::RIVM[:businessSection]
  enum :business_section_employees, predicate: NS::RIVM[:businessSectionEmployees]
  enum :comments_allowed, predicate: NS::RIVM[:commentsAllowed]
  enum :contact_allowed, predicate: NS::RIVM[:contactAllowed]
end
