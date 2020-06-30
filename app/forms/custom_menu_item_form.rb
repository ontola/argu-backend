# frozen_string_literal: true

class CustomMenuItemForm < ApplicationForm
  field :raw_label
  field :label_translation
  field :raw_image
  field :raw_href
  field :order
end
