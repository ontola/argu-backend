# frozen_string_literal: true

class Intervention < Edge
  include Edgeable::Content
  extend InterventionOptions
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable

  parentable :intervention_type

  property :goal, :text, NS::RIVM[:interventionGoal]
  property :specific_tools_required, :text, NS::RIVM[:specificToolsRequired]
  property :additional_introduction_information, :text, NS::RIVM[:additionalIntroductionInformation]
  property :plans_and_procedure, :integer, NS::RIVM[:plansAndProcedure], array: true, enum: plans_and_procedure_options
  property(
    :people_and_resources,
    :integer, NS::RIVM[:peopleAndResources],
    array: true,
    enum: people_and_resources_options
  )
  property :competence, :integer, NS::RIVM[:competence], array: true, enum: competence_options
  property :communication, :integer, NS::RIVM[:communication], array: true, enum: communication_options
  property(
    :motivation_and_commitment,
    :integer,
    NS::RIVM[:motivationAndCommitment],
    array: true,
    enum: motivation_and_commitment_options
  )
  property(
    :conflict_and_prioritization,
    :integer,
    NS::RIVM[:conflictAndPrioritization],
    array: true,
    enum: conflict_and_prioritization_options
  )
  property :ergonomics, :integer, NS::RIVM[:ergonomics], array: true, enum: ergonomics_options
  property :tools, :integer, NS::RIVM[:tools], array: true, enum: tools_options
  property :target_audience, :integer, NS::RIVM[:targetAudience], array: true, enum: target_audience_options
  property :risk_reduction, :integer, NS::RIVM[:riskReduction], array: true, enum: risk_reduction_options
  property :continuous, :integer, NS::RIVM[:continuous], array: true, enum: continuous_options
  property :independent, :integer, NS::RIVM[:independent], array: true, enum: independent_options
  property(
    :management_involvement,
    :integer,
    NS::RIVM[:managementInvolvement],
    array: true,
    enum: management_involvement_options
  )
  property :training_required, :integer, NS::RIVM[:trainingRequired], array: true, enum: training_required_options

  validates :description, length: {maximum: 5000}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :goal, length: {maximum: 5000}
  validates :specific_tools_required, length: {maximum: 5000}
  validates :additional_introduction_information, length: {maximum: 5000}
  validate :validate_parent_type

  private

  def validate_parent_type
    errors.add(:parent_id, "Invalid parent (#{parent.class})") unless parent.is_a?(InterventionType)
  end

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
