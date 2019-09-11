# frozen_string_literal: true

class DirectMessageForm < ApplicationForm
  fields [
    {email_address_id: {sh_in: -> { user_context.user.email_addresses }}},
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
end
