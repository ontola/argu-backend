# frozen_string_literal: true

class CustomMenuItemForm < ApplicationForm
  fields %i[
    raw_label
    label_translation
    raw_image
    raw_href
    order
  ]
end
