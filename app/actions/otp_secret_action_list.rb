# frozen_string_literal: true

class OtpSecretActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      type: NS::SCHEMA[:CreateAction],
      include_object: true,
      url: -> { LinkedRails.iri(path: 'users/otp_secrets') },
      object: nil,
      parent: nil,
      policy: :create?,
      root_relative_iri: '/users/otp_secrets/new',
      label: -> { I18n.t('actions.otp_secrets.create.label') },
      form: OtpSecretForm
    )
  )
  has_action(
    :destroy,
    destroy_options.merge(
      description: -> { I18n.t('actions.otp_secrets.destroy.description', name: resource.user.display_name) }
    )
  )
end
