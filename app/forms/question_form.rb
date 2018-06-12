# frozen_string_literal: true

class QuestionForm < FormsBase
  fields %i[
    display_name
    description
    map
    mark_as_important
    attachments
    advanced
    footer
  ]

  property_group :advanced,
                 label: I18n.t('forms.advanced'),
                 properties: %i[
                   require_location
                   pinned
                   reset_create_motion
                   default_sorting
                   expires_at
                   convert
                 ]

  property_group :footer,
                 properties: %i[
                   creator
                   publication_form
                 ]
end
