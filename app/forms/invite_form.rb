# frozen_string_literal: true

class InviteForm < ApplicationForm
  include RegexHelper

  field :token_type,
        input_field: LinkedRails::Form::Field::ToggleButtonGroup
  field :group_id,
        min_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in_prop: NS.argu[:grantedGroups]

  # for mail tokens
  field :addresses,
        input_field: MultipleEmailInput,
        min_count: 1,
        max_count: 5000,
        pattern: /(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+/
  field :message,
        input_field: LinkedRails::Form::Field::TextAreaInput,
        min_count: 1,
        max_length: 5000

  # for bearer tokens
  resource :bearer_token_collection,
           path: NS.argu[:bearerTokenCollection]

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :max_usages
    field :expires_at,
          input_field: LinkedRails::Form::Field::DateTimeInput
    field :redirect_url,
          min_count: 1
  end

  hidden do
    field :send_mail
  end

  footer do
    actor_selector
  end
end
