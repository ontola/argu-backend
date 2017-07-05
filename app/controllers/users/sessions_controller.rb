# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  skip_before_action :check_finished_intro, only: :destroy
  skip_before_action :verify_authenticity_token, only: :destroy

  def new
    request.flash[:notice] = I18n.t('devise.failure.invalid') if params[:show_error]
    self.resource = resource_class.new({remember_me: true, r: r_from_url_or_header}.merge(sign_in_params))
    clean_up_passwords(resource)
    respond_to do |format|
      format.html do
        render 'devise/sessions/new',
               layout: 'guest',
               locals: {resource: resource, resource_name: :user, devise_mapping: Devise.mappings[:user]}
      end
      format.js do
        render 'devise/sessions/new',
               layout: false,
               locals: {resource: resource, resource_name: :user, devise_mapping: Devise.mappings[:user]}
      end
    end
  end

  def create
    raise 'sessions#create is replaced with oauth/tokens#create'
  end

  def verify
    return if params[:host_url] != 'argu.freshdesk.com'
    if current_user.guest?
      redirect_to new_user_session_path(host_url: params[:host_url])
    else
      redirect_to freshdesk_redirect_url
    end
  end

  # DELETE /resource/sign_out
  def destroy
    send_event category: 'sessions',
               action: 'sign_out'
    doorkeeper_token.update!(expires_in: 0.seconds)
    sign_out
    set_flash_message! :notice, :signed_out
    respond_to_on_destroy
  end

  private

  def all_signed_out?
    !doorkeeper_token.acceptable?(:user)
  end

  # TODO: Code the 307 away
  def is_post?(r)
    r.match(/\/v(\?|\/)|\/c(\?|\/)/)
  end

  def freshdesk_redirect_url
    utctime = time_in_utc
    "#{Rails.application.secrets.freshdesk_url}login/sso?name=#{current_user.url}"\
      "&email=#{current_user.email}&timestamp=#{utctime}&hash=#{generate_hash_from_params_hash(utctime)}"
  end

  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?
    return unless current_resource_owner.present? && doorkeeper_token.acceptable?('user')

    flash[:alert] = I18n.t('devise.failure.already_authenticated')
    redirect_to after_sign_in_path_for(resource)
  end

  def r_from_url_or_header
    params[:r] || request.env['HTTP_TURBOLINKS_REFERRER'] || request.referer
  end

  def r_with_authenticity_token(r)
    uri = URI.parse(r)
    query = URI.decode_www_form(uri.query || '')
    query << ['authenticity_token', form_authenticity_token] if is_post?(r)
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end

  def generate_hash_from_params_hash(utctime)
    digest = OpenSSL::Digest::Digest.new('MD5')
    OpenSSL::HMAC.hexdigest(digest,
                            Rails.application.secrets.freshdesk_secret,
                            current_user.url + current_user.email + utctime)
  end

  def time_in_utc
    Time.current.utc.to_i.to_s
  end
end
