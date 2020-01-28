# frozen_string_literal: true

class BlogForm < ContainerNodeForm
  fields [
    :display_name,
    {bio: {datatype: NS::FHIR[:markdown]}},
    :locale,
    {url: url_options},
    :default_cover_photo,
    grants: grant_options
  ]
end
