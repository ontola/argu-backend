# frozen_string_literal: true

class HeadMiddleware
  INVALID_STATUS_CODE = -1
  include LinkedRails::Auth::AuthHelper
  include OauthHelper
  attr_reader :headers, :request

  def initialize(app)
    @app = app
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    prepare_request(env)

    resource = env[Rack::REQUEST_METHOD] == Rack::HEAD && resource_from_request
    status_code = status_code_for_request(resource)

    return @app.call(env) if status_code == INVALID_STATUS_CODE

    headers['Include-Resources'] = resource.try(:include_resources)&.join(',')

    Rails.logger.info "Completed HEAD #{status_code} #{Rack::Utils::HTTP_STATUS_CODES[status_code]}"

    [status_code, headers, []]
  end

  private

  def default_headers
    return {} if ActsAsTenant.current_tenant.blank?

    {
      'Content-Length' => '0',
      'Content-Type' => 'application/hex+x-ndjson'
    }
  end

  def resource_from_request
    return unless ActsAsTenant.current_tenant

    LinkedRails.iri_mapper.resource_from_iri(request.original_url, user_context)
  end

  def prepare_request(env)
    @request = ActionDispatch::Request.new(env)
    @headers = default_headers
  end

  def doorkeeper_render_error; end

  def redirect_request(actual_iri, resource)
    headers['Location'] = LinkedRails.iri(path: actual_iri).to_s

    Rails.logger.info "Redirecting #{request.fullpath} to #{resource.iri} (#{actual_iri})"

    302
  end

  def redirect_request?(actual_iri)
    !actual_iri.nil? && actual_iri != request.fullpath && !(actual_iri == '' && request.fullpath == '/')
  end

  def status_code_for_request(resource)
    return INVALID_STATUS_CODE if resource.blank?

    actual_iri = resource.try(:root_relative_iri)&.to_s

    return redirect_request(actual_iri, resource) if redirect_request?(actual_iri)

    Pundit.policy(user_context, resource).show? ? 200 : 403
  rescue ActiveRecord::RecordNotFound
    404
  rescue StandardError => e
    Bugsnag.notify(e)
    INVALID_STATUS_CODE
  end

  def update_oauth_token(token)
    headers['New-Refresh-Token'] = token.refresh_token
    headers['New-Authorization'] = token.token
  end
end
