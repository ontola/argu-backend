# frozen_string_literal: true

class Intervention < Edge # rubocop:disable Metrics/ClassLength
  include Edgeable::Content
  extend InterventionOptions
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance GrantResettable
  enhance ActivePublishable

  parentable :intervention_type

  property :employment_id, :linked_edge_id, NS::RIVM[:employmentId]
  property :goal, :text, NS::RIVM[:interventionGoal]
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
  property :nature_of_costs, :integer, NS::RIVM[:natureOfCosts], array: true, enum: nature_of_costs_options
  property :one_off_costs, :integer, NS::RIVM[:oneOffCosts], enum: one_off_costs_options
  property :recurring_costs, :integer, NS::RIVM[:recurringCosts], enum: recurring_costs_options
  property :cost_explanation, :text, NS::RIVM[:costExplanation]
  property :effectivity_research_method, :integer, NS::RIVM[:effectivityResearchMethod], enum: research_method_options
  property :security_improved, :integer, NS::RIVM[:securityImproved], enum: security_improved_options
  property :security_improvement_reason, :text, NS::RIVM[:securityImprovementReason]
  property :business_section, :integer, NS::RIVM[:businessSection], enum: business_section_options
  property :business_section_employees, :integer, NS::RIVM[:businessSectionEmployees], enum: section_employees_options
  property :comments_allowed, :integer, NS::RIVM[:commentsAllowed], enum: comments_allowed_options

  counter_cache true

  belongs_to :employment,
             foreign_key_property: :employment_id,
             class_name: 'Employment',
             dependent: false

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :goal, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :additional_introduction_information, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :cost_explanation, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :security_improvement_reason, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  # rubocop:disable Rails/Validation
  validates_presence_of(
    :goal, :risk_reduction, :continuous, :independent, :management_involvement, :training_required, :nature_of_costs,
    :one_off_costs, :recurring_costs, :effectivity_research_method, :security_improved, :business_section,
    :business_section_employees, :comments_allowed, :employment_id
  )
  # rubocop:enable Rails/Validation
  validate :validate_parent_type
  before_save :sync_comments_allowed

  def effects
    %i[plans_and_procedure people_and_resources competence communication
       motivation_and_commitment conflict_and_prioritization ergonomics tools].map do |attr|
      send(attr).map { |option| InterventionSerializer.enum_options(attr)[:options][option.to_sym][:iri] }
    end.flatten
  end

  def publish!
    super if employment.validated?
  end

  private

  def sync_comments_allowed
    current_reset = grant_resets.find_by(action: 'create', resource_type: 'Comment')
    if comments_are_allowed?
      self.grant_resets_attributes = [id: current_reset.id, _destroy: true] if current_reset
    else
      self.grant_resets_attributes = [action: 'create', resource_type: 'Comment'] unless current_reset
    end
  end

  def validate_parent_type
    errors.add(:parent_id, "Invalid parent (#{parent.class})") unless parent.is_a?(InterventionType)
  end

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
