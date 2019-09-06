# frozen_string_literal: true

class InterventionTypeForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :attachments
  ]
end
