# frozen_string_literal: true

class PhaseForm < ContainerNodeForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :order,
    :time,
    :attachments
  ]
end
