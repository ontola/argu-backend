# frozen_string_literal: true
require 'omniauth/omniauth_facebook'

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include NestedResourceHelper, OauthHelper, RedisResourcesHelper

  def self.provides_callback_for(provider)
    class_eval %{
      def #{provider}
        setup_provider(:#{provider})
      end
    }
  end

  [:twitter, :facebook].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.primary_email_record.email_verified?
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
    env['omniauth.params']['r'] || params[:r]
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
    redirect = if resource_or_scope.try(:r).present?
                 URI.decode(resource_or_scope.r) || root_path
               else
                 after_sign_in_path_for(resource_or_scope)
               end
    schedule_redis_resource_worker(GuestUser.new(id: session.id), resource_or_scope, redirect)
    redirect_to redirect
  end

  private

  def setup_provider(provider)
    connector = connector_for(provider)
    @user = User.find_for_oauth(request.env['omniauth.auth'])
    email = connector.email_for(request.env['omniauth.auth'])

    if @user.present?
      process_user(email)
    elsif (user_with_email = Email.where(email: email).first&.user).present?
      connect_user(provider, user_with_email)
    elsif current_user.guest? && email.present?
      create_new_user(provider, connector)
    elsif current_user.guest?
      # No connection, no current_user and no email..
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url(r: r_param(env))
    end
  end

  # Email already taken, but connection not present yet
  # so render connect accounts form
  # No identity created for this oauth connection
  def connect_user(provider, user_with_email)
    if current_user.guest? || current_user == user_with_email
      # TODO: Store in Redis when not found to prevent stale records
      identity = Identity.find_or_initialize_by uid: request.env['omniauth.auth']['uid'], provider: provider
      set_identity_fields_for provider, identity, request.env['omniauth.auth']
      raise NotImplementedError unless identity.save
      token = identity_token(identity)
      redirect_to connect_user_path(user_with_email, token: token, r: r_param(request.env))
    else
      flash[:error] = t('users.authentications.email_mismatch') if is_navigational_format?
      redirect_to root_path
    end
  end

  def connector_for(provider)
    if provider == :facebook
      Omniauth::OmniauthFacebook
    elsif provider == :twitter
      Omniauth::OmniauthTwitter
    end
  end

  # We have a new user! so show the 'need some details' form
  def create_new_user(provider, connector)
    identity = Identity.find_or_initialize_by uid: request.env['omniauth.auth']['uid'], provider: provider
    set_identity_fields_for provider, identity, request.env['omniauth.auth']
    user = connector.create_user_without_shortname(request.env['omniauth.auth'], identity, r_param(request.env))
    schedule_redis_resource_worker(GuestUser.new(id: session.id), user, r_param(request.env))
    setup_favorites(user)
    set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
    sign_in_and_redirect_with_r user
    send_event category: 'registrations',
               action: 'create',
               label: provider.to_s
  end

  def process_user(email)
    if current_user.guest?
      @user.update r: r_param(request.env) if r_param(request.env).present?
      sign_in_and_redirect_with_r @user, event: :authentication
    elsif current_user.email != email
      flash[:error] = t('users.authentications.email_mismatch') if is_navigational_format?
      redirect_to root_path
    elsif @user == current_user
      flash[:error] = t('devise.failure.already_authenticated') if is_navigational_format?
      redirect_to root_path
    end
  end

  def set_identity_fields_for(provider, identity, env)
    set_facebook_fields(identity, env) if provider == :facebook
  end
end
