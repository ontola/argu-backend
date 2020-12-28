# frozen_string_literal: true

class ProjectForm < ContainerNodeForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  has_one :default_cover_photo
  has_many :attachments
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
