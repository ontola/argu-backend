# frozen_string_literal: true
require 'argu/invalid_credentials_error'

class Oauth::TokensController < Doorkeeper::TokensController
  include ActionController::Cookies, ActionController::Redirecting
  include Rails.application.routes.url_helpers
  ARGU_HOST_MATCH = /^([a-zA-Z0-9|-]+\.{1})*(#{Regexp.quote(Rails.configuration.host)}|argu.co)$/

  def create
    return super unless argu_request?
    r = r_with_authenticity_token(params.dig(:user, :r) || '')
    response = authorize_response
    cookies.encrypted['client_token'] = response.token.token
    User.find(response.token.resource_owner_id).update r: ''
    redirect_to r.presence || root_path
  rescue Argu::InvalidCredentialsError
    redirect_to new_user_session_path(r: params.dig(:user, :r), show_error: true)
  end

  private

  def argu_request?
    match = request.env['HTTP_HOST'] =~ ARGU_HOST_MATCH
    !match.nil? && match >= 0
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
