# frozen_string_literal: true

class CustomMenuItemForm < ApplicationForm
  field :raw_label
  field :icon, input_field: IconInput
  field :raw_href
end
