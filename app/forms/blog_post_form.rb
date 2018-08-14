# frozen_string_literal: true

class BlogPostForm < FormsBase
  fields %i[
    display_name
    description
    mark_as_important
    attachments
    footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: %i[
                   creator
                 ]
end
