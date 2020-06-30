# frozen_string_literal: true

class InviteForm < ApplicationForm
  include RegexHelper

  field :addresses, max_length: 5000, pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/
  field :message, max_length: 5000
  field :group_id, sh_in: -> { ActsAsTenant.current_tenant.groups.map(&:iri) }
  field :redirect_url

  hidden do
    field :send_mail
  end

  footer do
    actor_selector
  end
end
