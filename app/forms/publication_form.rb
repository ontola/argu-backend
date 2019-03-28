# frozen_string_literal: true

class PublicationForm < ApplicationForm
  fields [
    draft: {default_value: true}
  ]
end
