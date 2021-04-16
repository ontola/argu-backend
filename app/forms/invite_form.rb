# frozen_string_literal: true

require 'input_fields/multiple_email_input'

class InviteForm < ApplicationForm
  include RegexHelper

  field :addresses,
        input_field: MultipleEmailInput,
        max_length: 5000,
        pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/
  field :message, max_length: 5000
  field :group_id, sh_in: -> { collection_iri(nil, :groups) }
  field :redirect_url

  hidden do
    field :send_mail
  end

  footer do
    actor_selector
  end
end
