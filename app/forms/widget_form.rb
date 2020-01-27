# frozen_string_literal: true

class WidgetForm < ApplicationForm
  fields [
    {raw_resource_iri: {max_length: 5000}},
    :view,
    :size,
    :position
  ]
end
