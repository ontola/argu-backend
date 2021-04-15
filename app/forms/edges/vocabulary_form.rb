# frozen_string_literal: true

class VocabularyForm < ApplicationForm
  field :display_name
  field :url
  field :description, datatype: NS::FHIR[:markdown]
  field :tagged_label
  has_one :default_cover_photo
  has_many :attachments

  with_collection :terms
end
