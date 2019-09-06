# frozen_string_literal: true

class InterventionForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    {
      parent_id: {
        min_count: 1,
        sh_in: lambda {
          iri_from_template(:intervention_types_collection_iri, page: 1, page_size: 100, fragment: :members)
        },
        datatype: NS::XSD[:string],
        default_value: -> { target.parent.is_a?(InterventionType) ? target.parent.iri : nil }
      }
    },
    :goal_and_effect,
    :intervention_introduction,
    :attachments
  ]

  property_group(
    :goal_and_effect,
    label: -> { I18n.t('forms.goal_and_effect.label') },
    description: -> { I18n.t('forms.goal_and_effect.description') },
    properties: [
      :goal,
      {target_audience: {max_count: 99}},
      :risk_reduction,
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
      {tools: {max_count: 99}}
    ]
  )

  property_group(
    :intervention_introduction,
    label: -> { I18n.t('forms.intervention_introduction.label') },
    description: -> { I18n.t('forms.intervention_introduction.description') },
    properties: %i[
      continuous independent specific_tools_required management_involvement training_required
      additional_introduction_information
    ]
  )
end
