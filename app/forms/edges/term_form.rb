# frozen_string_literal: true

class TermForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :position
  has_one :default_cover_photo
  has_many :attachments

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :color,
          input_field: LinkedRails::Form::Field::ColorInput
    field :icon,
          input_field: IconInput
    field :exact_match
  end
end
