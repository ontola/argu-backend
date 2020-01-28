# frozen_string_literal: true

class MotionForm < ApplicationForm
  visibility_text

  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :default_cover_photo,
    :attachments,
    :custom_placement,
    :advanced,
    :hidden,
    :footer
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
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]

  property_group :hidden,
                 iri: NS::ONTOLA[:hiddenGroup],
                 order: 98,
                 properties: %i[argu_publication]
end
