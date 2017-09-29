# frozen_string_literal: true

require 'argu'
require 'argu/controller/error_handling'

module Oauth
  class TokensController < Doorkeeper::TokensController
    include RedisResourcesHelper
    include OauthHelper
    include JsonApiHelper
    include ActionController::RequestForgeryProtection
    include ActionController::Cookies
    include ActionController::MimeResponds
    include ActionController::Redirecting
    include ActionController::Rescue
    include Rails.application.routes.url_helpers
    include Argu::ErrorHandling

    ARGU_HOST_MATCH = /^([a-zA-Z0-9|-]+\.{1})*(#{Regexp.quote(Rails.configuration.host_name)}|argu.co)(:[0-9]{0,5})?$/
    FRONTEND_HOST = URI(Rails.configuration.frontend_url).host.freeze

    def create
      return super unless argu_classic_frontend_request?
      r = r_with_authenticity_token
      remember_me = %w[1 true].include?(params[:user].try(:[], :remember_me) || params[:remember_me])
      guest_session_id = session.id
      response = authorize_response
      if response.is_a?(Doorkeeper::OAuth::ErrorResponse)
        raise Doorkeeper::Errors::DoorkeeperError.new(response.name)
      end
      set_argu_client_token_cookie(
        response.token.token,
        remember_me ? response.token.created_at + response.token.expires_in : nil
      )
      resource = User.find(response.token.resource_owner_id)
      resource.update r: ''
      schedule_redis_resource_worker(GuestUser.new(id: guest_session_id), resource, r) if guest_session_id.present?
      redirect_to r.presence || root_path
    rescue Doorkeeper::Errors::DoorkeeperError => e
      handle_doorkeeper_error(e)
    end

    private

    def argu_classic_frontend_request?
      return false if params['client_id'].present?
      match = request.env['HTTP_HOST'] =~ ARGU_HOST_MATCH
      !match.nil? && match >= 0 || request.env['HTTP_HOST'] == 'backend'
    end

    def handle_doorkeeper_error(e)
      handle_token_exception e
    end

    def is_post?(r)
      r.match(%r{\/v(\?|\/)|\/c(\?|\/)})
    end

    def r_with_authenticity_token
      r = params.dig(:user, :r) || params[:r]
      return '' if r.blank?

      uri = URI.parse(r)
      query = URI.decode_www_form(uri.query || '')
      query << ['authenticity_token', form_authenticity_token] if is_post?(r)
      uri.query = URI.encode_www_form(query) if query.present?
      uri.to_s
    end
  end
end
