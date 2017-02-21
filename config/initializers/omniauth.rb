# frozen_string_literal: true
Rails.application.config.middleware.use OmniAuth::Builder do
  callback_path = lambda do |env|
    return if env['omniauth.strategy'].nil?
    if env['rack.request.query_hash'].try(:[], 'r').present?
      query_param = {r: env['rack.request.query_hash']['r']}.to_param
    end
    env['omniauth.strategy'].instance_variable_set(
      :@current_path,
      [
        "#{env['omniauth.strategy'].path_prefix}/#{env['omniauth.strategy'].name}/callback",
        query_param
      ].compact.join('?')
    )
  end

  provider :facebook,
           Rails.application.secrets.facebook_key,
           Rails.application.secrets.facebook_secret,
           scope: 'email',
           secure_image_url: true,
           image_size: 'large',
           callback_path: callback_path,
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
