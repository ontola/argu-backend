# frozen_string_literal: true

module Users
  class OtpImagesController < AuthorizedController
    active_response :show

    private

    def check_if_registered?
      true
    end

    def data_url
      [
        'data:image/svg+xml;base64,',
        RQRCode::QRCode.new(provisioning_url).as_svg(module_size: 4).to_s
      ].pack('A*m').delete("\n")
    end

    def issuer
      return ActsAsTenant.current_tenant.display_name if Rails.env.production?

      "#{ActsAsTenant.current_tenant.display_name} #{Rails.env}"
    end

    def otp_secret
      @otp_secret ||= OtpSecret.find_or_create_by!(user_id: current_user&.id)
    end

    def policy(_resource)
      OtpImagePolicy.new(user_context, nil)
    end

    def provisioning_url
      otp_secret.provisioning_uri(current_user.email, issuer: issuer)
    end

    def requested_resource
      @requested_resource ||=
        LinkedRails::MediaObject.new(
          content_url: data_url,
          content_type: 'image/png',
          iri: LinkedRails.iri(path: 'users/otp_qr')
        )
    end
  end
end
