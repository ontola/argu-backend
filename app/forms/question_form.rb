# frozen_string_literal: true

class QuestionForm < FormsBase
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
                   require_location
                   pinned
                   default_sorting
                   expires_at
                 ]

  property_group :footer,
                 properties: %i[
                   creator
                 ]
end
