# frozen_string_literal: true

class TermForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :position
  has_one :default_cover_photo
  has_many :attachments
end
