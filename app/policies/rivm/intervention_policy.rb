# frozen_string_literal: true

class InterventionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[
      display_name description goal additional_introduction_information one_off_costs
      recurring_costs cost_explanation effectivity_research_method security_improved security_improvement_reason
      business_section business_section_employees comments_allowed
    ]
    attributes.concat %i[employment_id] unless user.guest? || (record.publisher && user != record.publisher)
    add_array_attributes(
      attributes,
      :plans_and_procedure, :people_and_resources, :competence, :communication, :motivation_and_commitment,
      :conflict_and_prioritization, :ergonomics, :tools, :target_audience, :risk_reduction, :continuous,
      :independent, :management_involvement, :training_required, :nature_of_costs
    )
    attributes.concat %i[parent_id] if new_record?
    attributes
  end

  def create?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def show?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def trash?
    super || is_creator?
  end
end
