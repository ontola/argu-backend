# frozen_string_literal: true

class Intervention < Edge # rubocop:disable Metrics/ClassLength
  include Edgeable::Content
  extend InterventionOptions
  enhance ProfilePhotoable
  enhance Attachable
  enhance Commentable
  enhance Contactable
  enhance Feedable
  enhance Statable
  enhance GrantResettable
  enhance ActivePublishable

  parentable :intervention_type

  property :show_organization_name, :boolean, NS::ARGU[:anonymous], default: true
  property :organization_name, :string, NS::ARGU[:organizationName]
  property :job_title, :string, NS::SCHEMA[:roleName]
  property :industry, :integer, NS::SCHEMA[:industry], enum: {
    argiculutre: 1, food_industry: 2, textile: 3, wood_industry: 4, paper_and_cardboard: 5, grafimedia: 6, chemistry: 7,
    rubber_and_plastic: 8, production_of_other_mineral_products: 9, metal: 10, metal_production: 11,
    manufacture_of_metal_products: 12, manufacture_of_electronics: 13, manufacture_of_electrical_appliances: 14,
    manufacture_of_other_machines_and_equipment: 15, car_industry: 16, manufacture_of_other_means_of_transport: 17,
    furniture_industry: 18, social_work_facilities: 19, repair_and_installation_of_machines: 20, energy_companies: 21,
    waste_treatment_and_recycling: 22, remediation_and_other_waste_management: 23,
    residential_building_and_construction_for_public_life: 24, ground_water_and_road_construction: 25,
    construction_industry: 26, car_trade_and_repair: 27, wholesale: 28, retail: 29, freight_transport: 30,
    inland_shipping: 31, transport_and_logistics: 32, catering_industry: 33, accommodation: 34,
    food_and_beverage_outlets: 35, rental_of_and_trade_in_real_estate: 36, architects_and_engineers: 37,
    rental_of_movable_property: 38, catering_cleaning_companies_and_gardeners: 39, other_business_services: 40,
    public_administration_and_government_services: 41, education: 42, healthcare: 43, nursing: 44, social_services: 45,
    sport_and_recreation: 46
  }
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
  property :continuous, :integer, NS::RIVM[:continuous], enum: continuous_options
  property :independent, :integer, NS::RIVM[:independent], enum: independent_options
  property(:management_involvement, :integer, NS::RIVM[:managementInvolvement], enum: management_involvement_options)
  property :training_required, :integer, NS::RIVM[:trainingRequired], enum: training_required_options
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
  property :contact_allowed, :integer, NS::RIVM[:contactAllowed], enum: contact_allowed_options

  counter_cache true

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :goal, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :additional_introduction_information, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :cost_explanation, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :security_improvement_reason, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :organization_name, presence: true, length: {maximum: 110}
  validates :job_title, presence: true, length: {maximum: 110}

  # rubocop:disable Rails/Validation
  validates_presence_of(
    :goal, :risk_reduction, :continuous, :independent, :management_involvement, :training_required, :nature_of_costs,
    :one_off_costs, :recurring_costs, :effectivity_research_method, :security_improved, :business_section,
    :business_section_employees, :comments_allowed, :contact_allowed, :target_audience, :industry
  )
  # rubocop:enable Rails/Validation
  validate :validate_parent_type
  before_save :sync_comments_allowed
  def initialize(*args)
    super
  end

  def effects
    %i[plans_and_procedure people_and_resources competence communication
       motivation_and_commitment conflict_and_prioritization ergonomics tools].map do |attr|
      send(attr)
        .reject { |option| option.start_with?('no_') }
        .map { |option| InterventionSerializer.enum_options(attr)[option.to_sym].iri }
    end.flatten
  end

  def public_organization_name
    return organization_name if show_organization_name?

    "Een bedrijf in de #{I18n.t("interventions.industry.#{industry}").downcase} industrie"
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

    def require_profile_photo?
      false
    end

    def sort_options(collection)
      return super if collection.type == :infinite

      [
        NS::SCHEMA[:name],
        NS::SCHEMA[:dateCreated],
        NS::RIVM[:oneOffCostsScore],
        NS::RIVM[:recurringCostsScore],
        NS::RIVM[:securityImprovedScore]
      ]
    end
  end
end
