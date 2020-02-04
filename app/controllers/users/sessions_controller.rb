# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def new # rubocop:disable Metrics/AbcSize
      request.flash[:notice] = I18n.t('devise.failure.invalid') if params[:show_error]
      request.flash[:notice] = params[:notice] if params[:notice]
      self.resource = resource_class.new({remember_me: true, r: r_from_url_or_header}.merge(sign_in_params))
      clean_up_passwords(resource)
      respond_with_redirect location: RDF::DynamicURI(path_with_hostname('/u/sign_in')).path
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
      r.match(%r{\/v(\?|\/)|\/c(\?|\/)})
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
      redirect = params[:r] || request.env['HTTP_TURBOLINKS_REFERRER'] || request.referer
      begin
        route_opts = Rails.application.routes.recognize_path(redirect)
        redirect if !route_opts || route_opts[:controller] != 'users/passwords'
      rescue ActionController::RoutingError
        redirect
      end
    end

    def r_with_authenticity_token
      r = params.dig(:user, :r) || params[:r]
      return '' if r.blank?

      uri = URI.parse(r)
      query = URI.decode_www_form(uri.query || '')
      query << ['authenticity_token', form_authenticity_token] if is_post?(r)
      uri.query = URI.encode_www_form(query)
      uri.to_s
    end

    def respond_to_on_destroy
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) do
          r = params.dig(:user, :r) || params[:r]
          if r.present? && argu_iri_or_relative?(r)
            redirect_to r
          else
            redirect_back(fallback_location: root_path)
          end
        end
      end
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
end
