# frozen_string_literal: true

class OtpImagePolicy < RestrictivePolicy
  def show?
    return forbid_with_message(I18n.t('messages.otp_secrets.already_exists')) if user.otp_active?

    !user.guest?
  end
end
