# frozen_string_literal: true

class DirectMessageForm < ApplicationForm
  fields [
    {
      email_address_id: {
        default_value: lambda {
          has_confirmed_email_addresses? ? user_context.user.primary_email_record.iri : nil
        },
      sh_in: -> { collection_iri(user_context.user, :email_addresses, filter: {CGI.escape(NS::ARGU[:confirmed]) => 'yes'}) }
      }
    },
    :subject,
    {body: {max_length: 5000}},
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   actor: actor_selector
                 ]

  private

  def confirmed_email_addresses
    user_context.user.email_addresses.confirmed
  end

  def has_confirmed_email_addresses?
    confirmed_email_addresses.any?
  end
end
