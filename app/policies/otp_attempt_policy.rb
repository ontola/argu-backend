# frozen_string_literal: true

class OtpAttemptPolicy < RestrictivePolicy
  permit_attributes %i[otp_attempt]

  def show?
    user.guest?
  end

  def create?
    user.guest? && record.active?
  end
end
