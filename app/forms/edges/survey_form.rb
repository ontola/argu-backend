# frozen_string_literal: true

class SurveyForm < ContainerNodeForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :external_iri, min_count: 1
  field :reward, input_field: MoneyInput
  has_one :default_cover_photo
  has_one :custom_placement

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :pinned
    field :expires_at
  end

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
