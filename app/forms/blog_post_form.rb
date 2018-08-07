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
                 properties: %i[
                   creator
                 ]
end
