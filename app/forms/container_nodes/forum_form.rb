# frozen_string_literal: true

class ForumForm < ContainerNodeForm
  fields [
    :display_name,
    {bio: {datatype: NS::FHIR[:markdown]}},
    :locale,
    {url: url_options},
    :default_cover_photo,
    :custom_placement,
    grants: grant_options
  ]
end
