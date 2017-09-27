# frozen_string_literal: true

Devise::MultiEmail.configure do |config|
  config.emails_association_name = :email_addresses
end
