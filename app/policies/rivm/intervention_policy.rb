# frozen_string_literal: true

class InterventionPolicy < EdgePolicy
  permit_attributes %i[
    display_name description goal additional_introduction_information one_off_costs
    recurring_costs cost_explanation effectivity_research_method security_improved security_improvement_reason
    business_section business_section_employees comments_allowed contact_allowed
    organization_name job_title industry show_organization_name
  ]
  permit_array_attributes %i[
    plans_and_procedure people_and_resources competence communication motivation_and_commitment
    conflict_and_prioritization ergonomics tools target_audience risk_reduction continuous
    independent management_involvement training_required nature_of_costs
  ]
  permit_attributes %i[parent_id], new_record: true
  permit_nested_attributes %i[default_profile_photo], new_record: true

  def create?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def contact?
    return forbid_with_message(I18n.t('actions.direct_messages.create.disabled.guest')) if user.guest?
    return true if record.contact_is_allowed? || super

    forbid_with_message(I18n.t('actions.direct_messages.create.disabled.not_allowed'))
  end

  def show?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def trash?
    super || is_creator?
  end
end
