# frozen_string_literal: true
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
           Rails.application.secrets.facebook_key,
           Rails.application.secrets.facebook_secret,
           scope: 'email',
           secure_image_url: true,
           image_size: 'large',
           client_options: {
             site: 'https://graph.facebook.com/v2.8',
             authorize_url: 'https://www.facebook.com/v2.8/dialog/oauth',
             ssl: {
               ca_file: "#{Rails.root}/config/ca-bundle.crt"
             }
           },
           token_params: {
             parse: :json
           }

  provider :twitter,
           Rails.application.secrets.twitter_key,
           Rails.application.secrets.twitter_secret,
           x_auth_access_type: 'write'

  # provider :openid, :store => OpenID::Store::Filesystem.new('/tmp'), name: 'openid'
end
