# frozen_string_literal: true

class DirectMessageForm < ApplicationForm
  field :email_address_id,
        sh_in: -> { collection_iri(nil, :email_addresses, filter: {CGI.escape(NS.argu[:confirmed]) => 'yes'}) }
  field :subject
  field :body, max_length: 5000

  footer do
    actor_selector(:actor)
  end
end
