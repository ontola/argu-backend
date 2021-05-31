# frozen_string_literal: true

class CustomActionForm < ApplicationForm
  field :raw_label
  field :raw_description, max_length: 5000
  field :raw_submit_label
  field :href
end
