# frozen_string_literal: true

class MeasureForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :comments_allowed,
    :attachments
  ]
end
