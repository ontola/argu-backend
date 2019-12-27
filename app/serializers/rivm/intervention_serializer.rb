# frozen_string_literal: true

class InterventionSerializer < ContentEdgeSerializer
  has_one :employment, predicate: NS::RIVM[:employment]

  attribute :goal, predicate: NS::RIVM[:interventionGoal]
  attribute :plans_and_procedure, predicate: NS::RIVM[:plansAndProcedure]
  attribute :people_and_resources, predicate: NS::RIVM[:peopleAndResources]
  attribute :competence, predicate: NS::RIVM[:competence]
  attribute :communication, predicate: NS::RIVM[:communication]
  attribute :motivation_and_commitment, predicate: NS::RIVM[:motivationAndCommitment]
  attribute :conflict_and_prioritization, predicate: NS::RIVM[:conflictAndPrioritization]
  attribute :ergonomics, predicate: NS::RIVM[:ergonomics]
  attribute :tools, predicate: NS::RIVM[:tools]
  attribute :target_audience, predicate: NS::RIVM[:targetAudience]
  attribute :risk_reduction, predicate: NS::RIVM[:riskReduction]
  attribute :continuous, predicate: NS::RIVM[:continuous]
  attribute :independent, predicate: NS::RIVM[:independent]
  attribute :management_involvement, predicate: NS::RIVM[:managementInvolvement]
  attribute :training_required, predicate: NS::RIVM[:trainingRequired]
  attribute :additional_introduction_information, predicate: NS::RIVM[:additionalIntroductionInformation]
  attribute :effects, predicate: NS::RIVM[:interventionEffects]
  attribute :nature_of_costs, predicate: NS::RIVM[:natureOfCosts]
  attribute :one_off_costs, predicate: NS::RIVM[:oneOffCosts]
  attribute :recurring_costs, predicate: NS::RIVM[:recurringCosts]
  attribute :cost_explanation, predicate: NS::RIVM[:costExplanation]
  attribute :effectivity_research_method, predicate: NS::RIVM[:effectivityResearchMethod]
  attribute :security_improved, predicate: NS::RIVM[:securityImproved]
  attribute :security_improvement_reason, predicate: NS::RIVM[:securityImprovementReason]
  attribute :business_section, predicate: NS::RIVM[:businessSection]
  attribute :business_section_employees, predicate: NS::RIVM[:businessSectionEmployees]
  attribute :comments_allowed, predicate: NS::RIVM[:commentsAllowed]
  attribute :one_off_costs_score, predicate: NS::RIVM[:oneOffCostsScore]
  attribute :recurring_costs_score, predicate: NS::RIVM[:recurringCostsScore]
  attribute :security_improved_score, predicate: NS::RIVM[:securityImprovedScore]

  enum :plans_and_procedure
  enum :people_and_resources
  enum :competence
  enum :communication
  enum :motivation_and_commitment
  enum :conflict_and_prioritization
  enum :ergonomics
  enum :tools
  enum :target_audience
  enum :risk_reduction
  enum :continuous
  enum :independent
  enum :management_involvement
  enum :training_required
  enum :nature_of_costs
  enum :one_off_costs
  enum :recurring_costs
  enum :effectivity_research_method
  enum :security_improved
  enum :business_section
  enum :business_section_employees
  enum :comments_allowed

  def one_off_costs_score
    Intervention.one_off_costs[object.one_off_costs]
  end

  def recurring_costs_score
    Intervention.recurring_costs[object.recurring_costs]
  end

  def security_improved_score
    return if object.security_improved == 'unkown_security_improvement'

    Intervention.security_improveds[object.security_improved]
  end
end
