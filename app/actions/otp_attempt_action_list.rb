# frozen_string_literal: true

class OtpAttemptActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      type: NS::SCHEMA[:CreateAction],
      include_object: true,
      url: -> { resource.iri },
      object: nil,
      parent: nil,
      policy: :create?,
      label: -> { I18n.t('actions.otp_secrets.create.label') },
      form: OtpAttemptForm
    )
  )
end
