# frozen_string_literal: true

class UserForm < ApplicationForm
  fields %i[
    time_zone
    notifications_section
    authentication_section
    email_address_section
    privacy_section
  ]

  property_group(
    :notifications_section,
    label: -> { I18n.t('actions.users.notifications.label') },
    properties: %i[
      reactions_email
      news_email
    ]
  )

  property_group(
    :authentication_section,
    label: -> { I18n.t('actions.users.authentication.label') },
    properties: %i[
      url
      password
      current_password
    ]
  )

  property_group(
    :email_address_section,
    label: -> { I18n.t('email_addresses.plural') },
    properties: [
      email_addresses_table: {
        type: :resource,
        url: -> { collection_iri(user_context.user, :email_addresses, display: :settingsTable) }
      }
    ]
  )

  property_group(
    :privacy_section,
    label: -> { I18n.t('actions.users.privacy.label') },
    properties: [
      :has_analytics,
      :is_public,
      :show_feed,
      delete_button: {
        type: :resource,
        url: -> { delete_iri(user_context.user) }
      }
    ]
  )
end
