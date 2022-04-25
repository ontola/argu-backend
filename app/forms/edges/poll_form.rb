# frozen_string_literal: true

class PollForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  has_one :options_vocab,
          form: Vocabularies::OptionsVocabForm,
          min_count: 1
  has_one :default_cover_photo
  has_many :attachments

  hidden do
    field :is_draft
  end
end
