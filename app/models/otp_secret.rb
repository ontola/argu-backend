# frozen_string_literal: true

class OtpSecret < LinkedRails::Auth::OtpSecret
  def issuer_name
    Apartment::Tenant.current.humanize
  end
end
