# frozen_string_literal: true

class MotionForm < ApplicationForm
  include VisibilityHelper

  resource visibility_text: {
    description: -> { visible_for_string(target) },
    if: -> { target.new_record? }
  }
  fields %i[
    display_name
    description
    default_cover_photo
    attachments
    custom_placement
    advanced
    hidden
    footer
  ]

  property_group :advanced,
                 label: -> { I18n.t('forms.advanced') },
                 properties: [
                   {mark_as_important: {description: -> { mark_as_important_label(target) }}},
                   :pinned,
                   :expires_at
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
