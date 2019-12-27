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

  def nature_of_costs_options
    {
      purchase_of_license: 1,
      purchase_of_materials: 2,
      hiring_of_advisors: 3,
      use_of_advisors: 4,
      use_of_operational_employees: 5,
      use_of_managers: 6
    }
  end

  def one_off_costs_options
    {
      one_off_very_low: 1,
      one_off_low: 2,
      one_off_normal: 3,
      one_off_high: 4,
      one_off_very_high: 5
    }
  end

  def recurring_costs_options
    {
      recurring_very_low: 1,
      recurring_low: 2,
      recurring_normal: 3,
      recurring_high: 4,
      recurring_very_high: 5
    }
  end

  def research_method_options
    {
      no_effectivity_research: 1,
      effectivity_conversational_research: 2,
      effectivity_internal_research: 3,
      effectivity_external_research: 4,
      effectivity_scientific_research: 5
    }
  end

  def security_improved_options
    {
      no_security_improvement: 1,
      very_small_security_improvement: 2,
      small_security_improvement: 3,
      big_security_improvement: 4,
      very_big_security_improvement: 5
    }
  end

  def business_section_options
    {full_business: 1, part_of_business: 2}
  end

  def business_employees_options
    {
      business_0_49: 1,
      business_50_99: 2,
      business_100_249: 3,
      business_250_499: 4,
      business_500_999: 5,
      business_1000_2999: 6,
      business_3000_plus: 7
    }
  end

  def section_employees_options
    {
      business_section_0_49: 1,
      business_section_50_99: 2,
      business_section_100_249: 3,
      business_section_250_499: 4,
      business_section_500_999: 5,
      business_section_1000_2999: 6,
      business_section_3000_plus: 7
    }
  end

  def contact_allowed_options
    {contact_is_allowed: 1, contact_not_allowed: 2}
  end

  def comments_allowed_options
    {comments_are_allowed: 1, comments_not_allowed: 2}
  end
end
