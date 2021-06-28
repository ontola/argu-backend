# frozen_string_literal: true

class PhaseForm < ContainerNodeForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :order
  field :time
  has_many :attachments
end
