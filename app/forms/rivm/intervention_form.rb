# frozen_string_literal: true

class InterventionForm < ApplicationForm
  # rubocop:disable Metrics/BlockLength
  group :intervention_description, label: -> { I18n.t('forms.intervention_description.label') } do
    field :display_name
    field :description, datatype: NS::FHIR[:markdown]
    field :organization_name
    field :show_organization_name
    has_one :default_profile_photo
    field :industry
    field :job_title
    field :parent_id,
          min_count: 1,
          sh_in: lambda {
            InterventionType
              .root_collection(page_size: 100, sort: [{key: NS::SCHEMA[:name], direction: :asc}])
              .default_view
              .members_iri
          },
          datatype: NS::XSD[:string],
          input_field: LinkedRails::Form::Field::SelectInput
    resource :goal_and_effect,
             label: -> { I18n.t('forms.goal_and_effect.label') },
             description: -> { I18n.t('forms.goal_and_effect.description') }
    resource :target_audience_text, description: -> { I18n.t('forms.target_audience_text') }
    field :target_audience, min_count: 1, max_count: 99
    field :risk_reduction, min_count: 1, max_count: 99
    resource :goal_and_audience_info,
             description: -> { I18n.t('forms.goal_and_effect.goal_and_audience_info.description') },
             label: -> { I18n.t('forms.goal_and_effect.goal_and_audience_info.label') }
    field :plans_and_procedure, max_count: 99
    field :people_and_resources, max_count: 99
    field :competence, max_count: 99
    field :communication, max_count: 99
    field :motivation_and_commitment, max_count: 99
    field :conflict_and_prioritization, max_count: 99
    field :ergonomics, max_count: 99
    field :tools, max_count: 99
    field :goal
  end
  # rubocop:enable Metrics/BlockLength

  group :intervention_introduction,
        label: -> { I18n.t('forms.intervention_introduction.label') },
        description: -> { I18n.t('forms.intervention_introduction.description') } do
    field :continuous, input_field: LinkedRails::Form::Field::RadioGroup
    field :independent, input_field: LinkedRails::Form::Field::RadioGroup
    field :management_involvement, input_field: LinkedRails::Form::Field::RadioGroup
    field :training_required, input_field: LinkedRails::Form::Field::RadioGroup
    field :additional_introduction_information
  end

  group :costs_section,
        label: -> { I18n.t('forms.costs_section.label') },
        description: -> { I18n.t('forms.costs_section.description') } do
    field :nature_of_costs, min_count: 1, max_count: 99
    resource :cost_estimate, description: -> { I18n.t('forms.cost_estimate') }
    field :one_off_costs, input_field: LinkedRails::Form::Field::RadioGroup
    field :recurring_costs, input_field: LinkedRails::Form::Field::RadioGroup
    field :cost_explanation
  end

  group :effectivity_section, label: -> { I18n.t('forms.effectivity_section.label') } do
    field :effectivity_research_method, input_field: LinkedRails::Form::Field::RadioGroup
    field :security_improved, input_field: LinkedRails::Form::Field::RadioGroup
    field :security_improvement_reason
  end

  group :final_section, label: -> { I18n.t('forms.final_section.label') } do
    field :business_section, input_field: LinkedRails::Form::Field::RadioGroup
    field :business_section_employees, input_field: LinkedRails::Form::Field::RadioGroup
    field :contact_allowed, input_field: LinkedRails::Form::Field::RadioGroup
    field :comments_allowed, input_field: LinkedRails::Form::Field::RadioGroup
  end

  group :attachments_section, collapsible: false do
    has_many :attachments, description: -> { I18n.t('interventions.attachments.description') }
  end

  hidden do
    field :is_draft
  end
end
