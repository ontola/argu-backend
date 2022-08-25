# frozen_string_literal: true

class InviteForm < ApplicationForm
  include RegexHelper

  field :addresses,
        input_field: MultipleEmailInput,
        min_count: 1,
        max_count: 5000,
        pattern: /(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+/
  field :message,
        min_count: 1,
        max_length: 5000
  field :group_id,
        min_count: 1,
        sh_in: -> { ::Group.collection_iri }
  field :redirect_url,
        min_count: 1

  hidden do
    field :send_mail
  end

  footer do
    actor_selector
  end
end
