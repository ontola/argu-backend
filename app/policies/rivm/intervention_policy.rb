# frozen_string_literal: true

class InterventionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description goal additional_introduction_information specific_tools_required]
    add_array_attributes(
      attributes,
      :plans_and_procedure, :people_and_resources, :competence, :communication, :motivation_and_commitment,
      :conflict_and_prioritization, :ergonomics, :tools, :target_audience, :risk_reduction, :continuous,
      :independent, :management_involvement, :training_required
    )
    attributes.concat %i[parent_id] if new_record?
    attributes
  end
end
