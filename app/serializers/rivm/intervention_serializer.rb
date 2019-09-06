# frozen_string_literal: true

class InterventionSerializer < ContentEdgeSerializer
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
  attribute :specific_tools_required, predicate: NS::RIVM[:specificToolsRequired]
  attribute :additional_introduction_information, predicate: NS::RIVM[:additionalIntroductionInformation]

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
end
