# frozen_string_literal: true

module Pages
  class StyleForm < ApplicationForm
    field :primary_color,
          input_field: LinkedRails::Form::Field::ColorInput
    field :secondary_color,
          input_field: LinkedRails::Form::Field::ColorInput
    field :header_background
    field :header_text
    field :styled_headers
  end
end
