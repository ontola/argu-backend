# frozen_string_literal: true

class QuestionForm < ApplicationForm
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
                   :require_location,
                   :pinned,
                   :default_motion_sorting,
                   :expires_at
                 ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]

  property_group :hidden,
                 order: 98,
                 iri: NS::ONTOLA[:hiddenGroup],
                 properties: %i[argu_publication]
end
