# frozen_string_literal: true

class BlogForm < ContainerNodeForm
  fields [
    :display_name,
    :bio,
    :locale,
    {url: url_options},
    :default_cover_photo,
    grants: grant_options
  ]
end
