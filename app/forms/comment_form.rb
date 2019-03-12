# frozen_string_literal: true

class CommentForm < ApplicationForm
  fields %i[
    display_name
    description
    footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]
end
