# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
           Rails.application.secrets.facebook_key,
           Rails.application.secrets.facebook_secret,
           scope: 'email',
           secure_image_url: true,
           image_size: 'large',
           client_options: {
             site: 'https://graph.facebook.com/v3.2',
             authorize_url: 'https://www.facebook.com/v3.2/dialog/oauth',
             ssl: {
               ca_file: Rails.root.join('config', 'ca-bundle.crt').to_s
             }
           },
           token_params: {
             parse: :json
           }

  provider :twitter,
           Rails.application.secrets.twitter_key,
           Rails.application.secrets.twitter_secret,
           x_auth_access_type: 'write'
end

# @todo remove after new FE.
# The RailsCsrfProtection gem is no longer needed then, since protection is done in the FE.
module OmniAuth
  module RailsCsrfProtection
    class TokenVerifier
      def verified_request?
        return true if request.headers['X-ARGU-Back'] == 'true'

        super
      end
    end
  end
end
