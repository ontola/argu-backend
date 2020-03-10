# frozen_string_literal: true

class InterventionForm < ApplicationForm # rubocop:disable Metrics/ClassLength
  fields [
    :intervention_description,
    :intervention_introduction,
    :costs_section,
    :effectivity_section,
    :final_section,
    {attachments: {description: I18n.t('interventions.attachments.description')}},
    :hidden
  ]

  property_group(
    :intervention_description,
    label: -> { I18n.t('forms.intervention_description.label') },
    properties: [
      :display_name,
      {description: {datatype: NS::FHIR[:markdown]}},
      {
        employment_id: {
          min_count: 1,
          sh_in: lambda {
            iri_from_template(:employments_iri, page_size: 100)
          },
          datatype: NS::XSD[:string]
        }
      },
      {
        parent_id: {
          min_count: 1,
          sh_in: lambda {
            InterventionType
              .root_collection(page_size: 100, sort: [{key: NS::SCHEMA[:name], direction: :asc}])
              .default_view
              .members_iri
          },
          datatype: NS::XSD[:string],
          input_field: NS::ONTOLA['element/select'],
          default_value: -> { target.parent.is_a?(InterventionType) ? target.parent.iri : nil }
        }
      },
      {
        goal_and_effect: {
          type: :resource,
          label: -> { I18n.t('forms.goal_and_effect.label') },
          description: -> { I18n.t('forms.goal_and_effect.description') }
        }
      },
      {
        target_audience_text: {
          type: :resource,
          description: -> { I18n.t('forms.target_audience_text') }
        }
      },
      {target_audience: {min_count: 1, max_count: 99}},
      {risk_reduction: {min_count: 1, max_count: 99}},
      {
        goal_and_audience_info: {
          type: :resource,
          description: -> { I18n.t('forms.goal_and_effect.goal_and_audience_info.description') },
          label: -> { I18n.t('forms.goal_and_effect.goal_and_audience_info.label') }
        }
      },
      {plans_and_procedure: {max_count: 99}},
      {people_and_resources: {max_count: 99}},
      {competence: {max_count: 99}},
      {communication: {max_count: 99}},
      {motivation_and_commitment: {max_count: 99}},
      {conflict_and_prioritization: {max_count: 99}},
      {ergonomics: {max_count: 99}},
      {tools: {max_count: 99}},
      :goal
    ]
  )

  property_group(
    :intervention_introduction,
    label: -> { I18n.t('forms.intervention_introduction.label') },
    description: -> { I18n.t('forms.intervention_introduction.description') },
    properties: %i[
      continuous independent management_involvement training_required
      additional_introduction_information
    ]
  )

  property_group(
    :costs_section,
    label: -> { I18n.t('forms.costs_section.label') },
    description: -> { I18n.t('forms.costs_section.description') },
    properties: [
      {nature_of_costs: {max_count: 99}},
      {cost_estimate: {type: :resource, description: -> { I18n.t('forms.cost_estimate') }}},
      :one_off_costs,
      :recurring_costs,
      :cost_explanation
    ]
  )

  property_group(
    :effectivity_section,
    label: -> { I18n.t('forms.effectivity_section.label') },
    properties: [
      :effectivity_research_method,
      {security_improved: {input_field: NS::ONTOLA['element/input/radio']}},
      :security_improvement_reason
    ]
  )

  property_group(
    :final_section,
    label: -> { I18n.t('forms.final_section.label') },
    properties: [
      :business_section,
      {business_section_employees: {input_field: NS::ONTOLA['element/input/radio']}},
      :contact_allowed,
      :comments_allowed
    ]
  )

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: %i[argu_publication]
  )
end
