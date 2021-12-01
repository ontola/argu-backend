# frozen_string_literal: true

class OtpSecret < LinkedRails::Auth::OtpSecret
  def issuer_name
    Apartment::Tenant.current.humanize
  end

  class << self
    def interact_as_guest?
      true
    end

    def owner_for_otp(params, user_context)
      return super if params.key?(:session)

      user_context.user unless user_context.nil? || user_context.user.guest?
    end
  end
end
