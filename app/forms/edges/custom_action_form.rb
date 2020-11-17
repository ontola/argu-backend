# frozen_string_literal: true

class CustomActionForm < ApplicationForm
  field :raw_label
  field :label_translation
  field :raw_description, max_length: 5000
  field :description_translation
  field :raw_submit_label
  field :submit_label_translation
  field :href
end
