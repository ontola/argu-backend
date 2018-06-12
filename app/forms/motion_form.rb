# frozen_string_literal: true

class MotionForm < FormsBase
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
                 properties: [
                   :require_location,
                   :pinned,
                   # {reset_create_motion: :custom_grants_form},
                   :default_sorting,
                   :expires_at,
                   :invert_arguments,
                   :convert
                 ]

  property_group :footer,
                 properties: %i[
                   creator
                   publication_form
                 ]
end
