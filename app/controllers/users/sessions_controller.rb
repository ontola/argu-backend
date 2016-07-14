class Users::SessionsController < Devise::SessionsController
  skip_before_action :check_finished_intro, only: :destroy

  def new
    self.resource = resource_class.new({r: r_from_url_or_header}.merge(sign_in_params))
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
    if params[:user][:r].present?
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      r = r_with_authenticity_token(params[:user][:r] || '')
      resource.update r: ''
      redirect_to r
    else
      super
    end
  end

  def verify
    if params[:host_url] == 'argu.freshdesk.com'
      if current_user.present?
        redirect_to freshdesk_redirect_url
      else
        redirect_to user_session_path(host_url: params[:host_url])
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do
      if @current_user.nil? && cookies[:a_a].present?
        cookies[:a_a] = {value: '-1', expires: 1.year.ago}
      end
    end
  end

  private

  # TODO: Code the 307 away
  def is_post?(r)
    r.match(/\/v(\?|\/)|\/c(\?|\/)/)
  end

  def freshdesk_redirect_url
    utctime = time_in_utc
    "#{Rails.application.secrets.freshdesk_url}login/sso?name=#{current_user.url}"\
      "&email=#{current_user.email}&timestamp=#{utctime}&hash=#{generate_hash_from_params_hash(utctime)}"
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
