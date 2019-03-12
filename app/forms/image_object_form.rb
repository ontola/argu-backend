# frozen_string_literal: true

class ImageObjectForm < ApplicationForm
  fields %i[
    content
    position_y
  ]

  field :content_type,
        sh_in: ->(resource) { resource.form.target.allowed_content_types }
end
