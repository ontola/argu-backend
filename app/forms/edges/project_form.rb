# frozen_string_literal: true

class ProjectForm < ContainerNodeForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :current_phase_id,
        datatype: NS.xsd.string,
        max_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in_prop: NS.argu[:phases]
  has_one :default_cover_photo
  has_many :attachments
  has_one :placement

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
