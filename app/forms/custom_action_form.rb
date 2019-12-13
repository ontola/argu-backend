# frozen_string_literal: true

class CustomActionForm < ApplicationForm
  fields [
    :raw_label,
    :label_translation,
    {raw_description: {max_length: 5000}},
    :description_translation,
    :raw_submit_label,
    :submit_label_translation,
    :href
  ]
end
