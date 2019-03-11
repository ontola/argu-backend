# frozen_string_literal: true

class MediaObjectForm < RailsLD::Form
  fields %i[
    content
  ]

  field :content_type,
        sh_in: ->(resource) { resource.form.target.allowed_content_types }
end
