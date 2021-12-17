# frozen_string_literal: true

class VocabularyForm < ContainerNodeForm
  field :display_name
  field :url
  field :description, datatype: NS.fhir[:markdown]
  field :tagged_label
  field :term_type
  has_one :default_cover_photo
  has_many :attachments
  has_many :grants, **grant_options

  with_collection :terms
end
