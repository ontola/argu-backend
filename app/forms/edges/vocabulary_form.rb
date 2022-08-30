# frozen_string_literal: true

class VocabularyForm < ContainerNodeForm
  field :display_name
  field :url
  field :description, datatype: NS.fhir[:markdown]

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :default_term_display
    field :tagged_label
    field :term_type
  end

  has_one :default_cover_photo
  has_many :attachments
  with_collection :terms

  grants_group
end
