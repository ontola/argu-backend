# frozen_string_literal: true

class OtpSecretPolicy < RestrictivePolicy
  permit_attributes %i[otp_attempt]

  def show?
    current_user? || staff?
  end

  def create?
    return forbid_with_message(I18n.t('messages.otp_secrets.already_exists')) if user.otp_active?

    current_user?
  end

  def destroy?
    return forbid_with_message(I18n.t('messages.otp_secrets.not_activated')) unless record.active?

    current_user? || staff?
  end

  private

  def current_user?
    record.user_id == user.id
  end
end
