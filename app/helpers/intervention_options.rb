# frozen_string_literal: true

module InterventionOptions
  def plans_and_procedure_options
    {usability: 1, planning: 2, procedures: 3, responsibilities: 4, preparation: 5, other_plans: 6}
  end

  def people_and_resources_options
    {labor_force: 1, resources: 2, other_people_resource: 3}
  end

  def competence_options
    {craftsmanship: 1, training: 2, knowledge: 3, unexpected_situation: 4, other_competence: 5}
  end

  def communication_options
    {open_communication: 1, communication_processed: 2, communication_resources: 3, other_communication: 4}
  end

  def motivation_and_commitment_options
    {rules_and_behavior: 1, leading_by_example: 2, participation: 3, other_motivation: 4}
  end

  def conflict_and_prioritization_options
    {leadership_priorities: 1, consitent_leadership: 2, dilemmas: 3, other_conflict: 4}
  end

  def ergonomics_options
    {buttons_and_devices: 1, software: 2, housekeeping: 3, other_ergonomics: 4}
  end

  def tools_options
    {tool_availability: 1, design_process: 2, technical_state: 3, personal_protection: 4, other_tools: 5}
  end

  def target_audience_options
    {
      operational_employess: 1, contractors: 2, hired_peronel: 3, managers: 4,
      higher_management: 5, safety_professionals: 6, trainers: 7
    }
  end

  def risk_reduction_options
    {
      removal_from_danger: 1, change_of_technique: 2, technical_adjustment: 3, change_personal_protection: 4,
      change_knowledge: 5, change_behavior: 6, change_culture: 7, change_organisation: 8, unknown_reduction: 9
    }
  end

  def continuous_options
    {is_continuous: 1, is_not_continuous: 2, continuous_unknown: 3}
  end

  def independent_options
    {fully_independent: 1, optionally_independent: 2, external_party_required: 3}
  end

  def management_involvement_options
    {
      management_very_important: 1, management_important: 2,
      management_not_very_important: 3, management_not_important: 4
    }
  end

  def training_required_options
    {training_is_required: 1, training_is_not_required: 2, training_unkown_required: 3}
  end
end
