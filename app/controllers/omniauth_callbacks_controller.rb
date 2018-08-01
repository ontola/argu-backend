# frozen_string_literal: true

require 'omniauth/omniauth_facebook'

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include RedisResourcesHelper
  include OauthHelper
  include NestedResourceHelper

  def self.provides_callback_for(provider)
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{provider}
        setup_provider(:#{provider})
      end
    RUBY
  end

  %i[twitter facebook].each do |provider|
    provides_callback_for provider
  end

  private

  def after_sign_in_path_for(resource)
    return finish_signup_path(resource) unless resource.primary_email_record.email_verified?
    resource.shortname.present? ? super(resource) : setup_users_path
  end

  def connector
    if @provider == :facebook
      Omniauth::OmniauthFacebook
    elsif @provider == :twitter
      Omniauth::OmniauthTwitter
    end
  end

  def create_identity_for_current_user
    identity_from_response.user = current_user
    raise NotImplementedError unless identity_from_response.save
    set_flash_message(:notice, :success, kind: @provider.to_s.capitalize) if is_navigational_format?
    redirect_to r_param(request.env).presence || root_path
  end

  # We have a new user! so show the 'need some details' form
  def create_new_user
    user = connector.create_user_without_shortname(
      request.env['omniauth.auth'],
      identity_from_response,
      r_param(request.env)
    )
    schedule_redis_resource_worker(GuestUser.new(id: session_id), user, r_param(request.env))
    setup_favorites(user)
    set_flash_message(:notice, :success, kind: @provider.to_s.capitalize) if is_navigational_format?
    sign_in_and_redirect_with_r user
  end

  def identity_from_response
    return @identity if @identity.present?
    @identity ||= Identity.find_or_initialize_by(uid: request.env['omniauth.auth']['uid'], provider: @provider)
    set_facebook_fields(@identity, request.env['omniauth.auth']) if @provider == :facebook
    set_twitter_fields(@identity, request.env['omniauth.auth']) if @provider == :twitter
    @identity
  end

  # Email already taken, but no connected Identity present yet
  def process_existing_email(email)
    return if (user = User.joins(:email_addresses).find_by(email_addresses: {email: email})).blank?
    if current_user.guest?
      raise NotImplementedError unless identity_from_response.save
      token = identity_token(identity_from_response)
      redirect_to connect_user_path(user, token: token, r: r_param(request.env))
    elsif current_user == user
      create_identity_for_current_user
    else
      flash[:error] = t('users.authentications.email_mismatch') if is_navigational_format?
      redirect_to root_path
    end
  end

  def process_existing_identity
    return if (user = User.find_for_oauth(request.env['omniauth.auth'])).blank?
    if current_user.guest?
      user.update r: r_param(request.env) if r_param(request.env).present?
      sign_in_and_redirect_with_r user, event: :authentication
    elsif user == current_user
      flash[:error] = t('devise.failure.already_authenticated') if is_navigational_format?
      redirect_to root_path
    else
      flash[:error] = t('users.authentications.email_mismatch') if is_navigational_format?
      redirect_to root_path
    end
  end

  def process_new_identity(email)
    if email.blank?
      # No connection, no current_user and no email..
      session["devise.#{@provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url(r: r_param(request.env)), notice: t('sign_in_facebook_failure')
    elsif current_user.guest?
      create_new_user
    else
      EmailAddress.create!(user: current_user, email: email, confirmed_at: Time.current)
      create_identity_for_current_user
    end
  end

  def r_param(env)
    r = env['omniauth.params']['r'] || params[:r]
    argu_iri_or_relative?(r) ? r : nil
  end

  def set_facebook_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
  end

  def set_twitter_fields(identity, auth)
    identity.access_token = auth['credentials']['token']
    identity.access_secret = auth['credentials']['secret']
  end

  def setup_provider(provider)
    @provider = provider
    email = connector.email_for(request.env['omniauth.auth'])
    process_existing_identity || process_existing_email(email) || process_new_identity(email)
  end

  def sign_in_and_redirect_with_r(resource_or_scope, *args)
    sign_in resource_or_scope, *args
    redirect =
      if resource_or_scope.try(:r).present?
        resource_or_scope.r || root_path
      else
        after_sign_in_path_for(resource_or_scope)
      end
    schedule_redis_resource_worker(GuestUser.new(id: session_id), resource_or_scope, redirect)
    redirect_to redirect
  end
end
