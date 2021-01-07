# frozen_string_literal: true

class OtpSecretForm < ApplicationForm
  resource :provision_image,
           description: -> { I18n.t('otp_secrets.form.provision_image.description') },
           url: -> { LinkedRails.iri(path: 'users/otp_qr') }
  field :otp_attempt, description: '', min_count: 1
end
