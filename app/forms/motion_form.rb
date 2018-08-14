# frozen_string_literal: true

class MotionForm < FormsBase
  fields %i[
    display_name
    description
    mark_as_important
    attachments
    advanced
    footer
  ]

  property_group :advanced,
                 label: I18n.t('forms.advanced'),
                 properties: %i[
                   pinned
                   expires_at
                   invert_arguments
                 ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: %i[
                   creator
                 ]
end
