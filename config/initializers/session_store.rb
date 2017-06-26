# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

Rails.application.config.session_store(
  :cookie_store,
  key: Rails.configuration.cookie_name,
  domain: :all,
  tld_length: Rails.env.staging? ? 3 : 2
)
