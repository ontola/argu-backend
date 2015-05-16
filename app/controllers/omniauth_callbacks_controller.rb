class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)

        if self.respond_to? :set_#{provider}_fields
          self.send :set_#{provider}_fields, env['omniauth.auth']
        end

        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end

  [:twitter, :facebook].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      super resource
    else
      finish_signup_path(resource)
    end
  end

  def set_facebook_fields(auth)
    i = Identity.find_by(uid: auth[:uid])
    i.access_token = auth['credentials']['token']
    i.save
  end

  def set_twitter_fields(auth)
    i = Identity.find_by(uid: auth[:uid])
    i.access_token = auth['credentials']['token']
    i.access_secret = auth['credentials']['secret']
    i.save
  end

end
