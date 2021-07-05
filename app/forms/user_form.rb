# frozen_string_literal: true

class UserForm < ApplicationForm
  field :time_zone

  group :notifications_section, label: -> { I18n.t('actions.users.notifications.label') } do
    field :reactions_email
    field :news_email
  end

  group :authentication_section, label: -> { I18n.t('actions.users.authentication.label') } do
    field :password
    field :current_password
    resource :add_two_fa,
             url: -> { delete_iri('/u/otp_secret') }
    resource :remove_two_fa,
             url: -> { new_iri('/u/otp_secret') }
  end

  group :email_address_section, label: -> { EmailAddress.plural_label } do
    resource :email_addresses_table,
             url: -> { collection_iri(nil, :email_addresses, display: :settingsTable) }
  end

  group :privacy_section, label: -> { I18n.t('actions.users.privacy.label') } do
    field :has_analytics
    field :is_public
    field :show_feed
    resource :delete_button, url: -> { delete_iri('user') }
  end
end
