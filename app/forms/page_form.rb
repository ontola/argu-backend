# frozen_string_literal: true

class PageForm < ApplicationForm
  fields [
    {profile: {if: -> { target.new_record? }}},
    :visibility,
    :url,
    :last_accepted,
    :theme
  ]

  property_group :theme,
                 label: -> { I18n.t('forms.theme.label') },
                 description: -> { I18n.t('forms.theme.description') },
                 properties: %i[
                   navbar_color
                   navbar_background
                   accent_color
                   accent_background_color
                 ]
end
