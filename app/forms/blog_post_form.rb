# frozen_string_literal: true

class BlogPostForm < ApplicationForm
  fields [
    :display_name,
    :description,
    {mark_as_important: {description: ->(resource) { mark_as_important_label(resource) }}},
    :attachments,
    :advanced,
    :footer
  ]

  property_group :advanced,
                 label: I18n.t('forms.advanced'),
                 properties: %i[
                   argu_publication
                 ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]
end
