# frozen_string_literal: true

class TermForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :position
  has_one :default_cover_photo
  has_many :attachments

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :exact_match
  end
end
