# frozen_string_literal: true

class InviteForm < ApplicationForm
  include RegexHelper

  field :addresses,
        input_field: MultipleEmailInput,
        min_count: 1,
        max_count: 5000,
        pattern: /(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+/
  field :message,
        input_field: LinkedRails::Form::Field::TextAreaInput,
        min_count: 1,
        max_length: 5000
  field :group_id,
        min_count: 1,
        input_field: LinkedRails::Form::Field::SelectInput,
        sh_in_prop: NS.argu[:grantedGroups]
  field :redirect_url,
        min_count: 1

  hidden do
    field :send_mail
  end

  footer do
    actor_selector
  end
end
