# frozen_string_literal: true

class DirectMessageForm < ApplicationForm
  field :email_address_id,
        sh_in: -> { EmailAddress.collection_iri(filter: {NS.argu[:confirmed] => 'yes'}) }
  field :subject
  field :body,
        input_field: LinkedRails::Form::Field::TextAreaInput,
        max_length: 5000

  footer do
    actor_selector(:actor)
  end
end
