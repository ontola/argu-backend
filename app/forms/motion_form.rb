# frozen_string_literal: true

class MotionForm < ApplicationForm
  fields [
    :display_name,
    :description,
    :default_cover_photo,
    {mark_as_important: {description: ->(resource) { mark_as_important_label(resource) }}},
    :attachments,
    :custom_placement,
    :advanced,
    :footer
  ]

  property_group :advanced,
                 label: I18n.t('forms.advanced'),
                 properties: %i[
                   argu_publication
                   pinned
                   expires_at
                 ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]
end
