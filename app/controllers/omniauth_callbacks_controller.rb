# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include NestedResourceHelper

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        connector = Omniauth::Omniauth#{provider.capitalize}
        @user = User.find_for_oauth(env["omniauth.auth"])
        email = connector.email_for(env["omniauth.auth"])

        if @user.present?
          if current_user.blank?
            @user.update r: r_param(env) if r_param(env).present?
            sign_in_and_redirect_with_r @user, event: :authentication
          elsif current_user.email != email
            flash[:error] = t("users.authentications.email_mismatch") if is_navigational_format?
            redirect_to root_path
          elsif @user == current_user
            flash[:error] = t("devise.failure.already_authenticated") if is_navigational_format?
            redirect_to root_path
          end
        else
          if (user_with_email = User.where(email: email).first).present?
            # Email already taken, but connection not present yet
            # so render connect accounts form
            # No identity created for this oauth connection
            if current_user.blank? || current_user == user_with_email
              # TODO Store in Redis when not found to prevent stale records
              identity = Identity.find_or_initialize_by uid: env["omniauth.auth"]["uid"], provider: :#{provider}
              set_#{provider}_fields identity, env["omniauth.auth"]
              if identity.save
                token = identity_token(identity)
                redirect_to connect_user_path(user_with_email, token: token, r: r_param(env))
              else
                raise NotImplementedError
              end
            else
              flash[:error] = t("users.authentications.email_mismatch") if is_navigational_format?
              redirect_to root_path
            end
          elsif current_user.blank? && email.present?
            # We have a new user! so show the 'need some details' form
            identity = Identity.find_or_initialize_by uid: env["omniauth.auth"]["uid"], provider: :#{provider}
            set_#{provider}_fields identity, env["omniauth.auth"]
            user = connector.create_user_without_shortname(env["omniauth.auth"], identity, r_param(env))
            setup_memberships(user)
            set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
            sign_in_and_redirect_with_r user
          elsif current_user.blank?
            # No connection, no current_user and no email..
            session["devise.#{provider}_data"] = env["omniauth.auth"]
            redirect_to new_user_registration_url(r: r_param(env))
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

  def r_param(env)
    env['omniauth.params']['r']
  end

  def set_facebook_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
  end

  def set_twitter_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
    identity.access_secret = auth['credentials']['secret']
  end

  def sign_in_and_redirect_with_r(resource_or_scope, *args)
    sign_in resource_or_scope, *args
    if resource_or_scope.try(:r).present?
      r = URI.decode(resource_or_scope.r)
      redirect_to r.presence || root_path
    else
      redirect_to after_sign_in_path_for(resource_or_scope)
    end
  end
end
