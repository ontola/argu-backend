# frozen_string_literal: true

FactoryBot.define do
  factory :intervention do
    sequence(:title) { |n| "fg intervention title #{n}end" }
    sequence(:content) { |i| "fg intervention content #{i}end" }

    goal 'Goal'
    additional_introduction_information 'Additional introduction information'
    plans_and_procedure [:usability]
    risk_reduction [:change_knowledge]
    continuous [:is_continuous]
    independent [:fully_independent]
    management_involvement [:management_very_important]
    training_required [:training_is_required]
    nature_of_costs [:purchase_of_license]
    one_off_costs :one_off_normal
    recurring_costs :recurring_normal
    cost_explanation 'Cost explanation'
    effectivity_research_method :effectivity_internal_research
    security_improved :small_security_improvement
    security_improvement_reason 'Security improvement reason'
    business_section :full_business
    business_section_employees :business_section_100_249
    comments_allowed :comments_are_allowed
    contact_allowed :contact_is_allowed
  end
end
