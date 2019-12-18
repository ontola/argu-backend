# frozen_string_literal: true

class IncidentForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :attachments
  ]
end
