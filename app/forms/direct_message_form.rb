# frozen_string_literal: true

class DirectMessageForm < RailsLD::Form
  fields [
    {email: {sh_in: ->(r) { r.form.user_context.user.email_addresses }}},
    :subject,
    {body: {max_length: 5000}},
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   actor: actor_selector
                 ]
end
