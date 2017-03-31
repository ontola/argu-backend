# frozen_string_literal: true
require 'argu/invalid_credentials_error'

module Oauth
  class TokensController < Doorkeeper::TokensController
    include ActionController::Redirecting, ActionController::MimeResponds, ActionController::Cookies,
            ActionController::RequestForgeryProtection
    include Rails.application.routes.url_helpers
    ARGU_HOST_MATCH = /^([a-zA-Z0-9|-]+\.{1})*(#{Regexp.quote(Rails.configuration.host_name)}|argu.co)(:[0-9]{0,5})?$/
    FRONTEND_HOST = URI(Rails.configuration.frontend_url).host.freeze

    def create
      return super unless argu_classic_frontend_request?
      r = r_with_authenticity_token(params.dig(:user, :r) || '')
      remember_me = params[:user].try(:[], :remember_me) || params[:remember_me]
      response = authorize_response
      cookies.encrypted['argu_client_token'] = {
        expires: %w(1 true).include?(remember_me) ? response.token.created_at + response.token.expires_in : nil,
        value: response.token.token,
        secure: Rails.env.production?,
        httponly: true,
        domain: :all
      }
      User.find(response.token.resource_owner_id).update r: ''
      redirect_to r.presence || root_path
    rescue Argu::InvalidCredentialsError
      respond_to do |format|
        format.html { redirect_to new_user_session_path(r: r, show_error: true) }
        format.json do
          render status: 422,
                 json: {error: {code: 'WRONG_CREDENTIALS', message: 'wrong username or password'}}
        end
      end
    end

    private

    def argu_classic_frontend_request?
      return false if params['client_id'].present?
      match = request.env['HTTP_HOST'] =~ ARGU_HOST_MATCH
      !match.nil? && match >= 0 || request.env['HTTP_HOST'] == 'backend'
    end

    def is_post?(r)
      r.match(%r{\/v(\?|\/)|\/c(\?|\/)})
    end

    def r_with_authenticity_token(r)
      return '' unless r.present?
      uri = URI.parse(r)
      query = URI.decode_www_form(uri.query || '')
      query << ['authenticity_token', form_authenticity_token] if is_post?(r)
      uri.query = URI.encode_www_form(query) if query.present?
      uri.to_s
    end
  end
end
