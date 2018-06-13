# frozen_string_literal: true

class CommentForm < FormsBase
  fields %i[
    display_name
    description
    footer
  ]

  property_group :footer,
                 properties: %i[
                   creator
                 ]
end
