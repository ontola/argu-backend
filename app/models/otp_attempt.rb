# frozen_string_literal: true

class OtpAttempt < LinkedRails::Auth::OtpAttempt
  class << self
    def interact_as_guest?
      true
    end

    def user_for_otp(params, user_context)
      return super if params.key?(:session)

      user_context.user unless user_context.user.guest?
    end
  end
end
