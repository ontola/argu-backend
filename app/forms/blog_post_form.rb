# frozen_string_literal: true

class BlogPostForm < ApplicationForm
  fields [
    :display_name,
    :description,
    :default_cover_photo,
    {mark_as_important: {description: ->(resource) { mark_as_important_label(resource) }}},
    :attachments,
    :hidden,
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]

  property_group :hidden,
                 iri: NS::ONTOLA[:hiddenGroup],
                 properties: %i[argu_publication]
end
