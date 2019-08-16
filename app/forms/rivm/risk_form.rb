# frozen_string_literal: true

class RiskForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :url,
    :attachments
  ]
end
