# frozen_string_literal: true

class PhaseForm < ContainerNodeForm
  field :display_name
  field :resource_type, min_count: 1
  field :description, datatype: NS.fhir[:markdown]
  field :position
  field :time
  has_many :attachments
end
