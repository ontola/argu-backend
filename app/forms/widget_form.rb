# frozen_string_literal: true

class WidgetForm < ApplicationForm
  field :raw_resource_iri, max_length: 5000
  field :view
  field :size
end
