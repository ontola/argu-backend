# frozen_string_literal: true

class MediaObjectForm < ApplicationForm
  fields %i[
    content
  ]

  field :content_type,
        sh_in: -> { target.allowed_content_types }
end
