class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        connector = Omniauth::Omniauth#{provider.capitalize}
        @user = User.find_for_oauth(env["omniauth.auth"])
        email = connector.email_for(env["omniauth.auth"])

        if @user.present?
          if current_user.blank?
            sign_in_and_redirect @user, event: :authentication
          elsif @user.email.present? && @user.email == current_user.email
            unless @user == current_user
              # Show message that the connection is connected to another account
              fsfdsa1
            end
          end
        else
          if (user_with_email = User.where(email: email).first).present?
            # Email already taken, but connection not present yet
            # so render connect accounts form
            # No identity created for this oauth connection
            if current_user.blank?
              #redirect_to connect_user_path(user_with_email, auth: env["omniauth.auth"].to_json)
              identity = Identity.find_or_initialize_by uid: env["omniauth.auth"]["uid"], provider: :#{provider} # TODO Store in Redis when not found to prevent stale records
              set_#{provider}_fields identity, env["omniauth.auth"]
              if identity.save
                token = identity_token(identity)
                redirect_to connect_user_path(user_with_email, token: token)
              else
                raise NotImplementedError
              end
            else
              # Old user, new connection
              # Check if user with email from connection can be found
              fsfdsa3
            end
          elsif current_user.blank? && email.present?
            # We have a new user! so show the 'need some details' form
            identity = Identity.find_or_initialize_by uid: env["omniauth.auth"]["uid"], provider: :#{provider}
            set_#{provider}_fields identity, env["omniauth.auth"]
            user = connector.create_user_without_shortname(env["omniauth.auth"], identity)
            set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
            sign_in_and_redirect user
          elsif current_user.blank?
            # No connection, no current_user and no email..
            session["devise.#{provider}_data"] = env["omniauth.auth"]
            redirect_to new_user_registration_url
          end
        end
      end
    }
  end

  [:twitter, :facebook].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
        if resource.shortname.present?
          super resource
        else
          setup_users_path
        end
    else
      finish_signup_path(resource)
    end
  end

  def set_facebook_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
  end

  def set_twitter_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
    identity.access_secret = auth['credentials']['secret']
  end

end
