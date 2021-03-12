# frozen_string_literal: true

class OtpSecretPolicy < LinkedRails::Auth::OtpSecretPolicy
  private

  def administrate_otp?
    staff?
  end
end
