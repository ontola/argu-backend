# frozen_string_literal: true

class HeadMiddleware
  include IRIHelper
  include Argu::Controller::Authentication
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

    return @app.call(env) unless resource

    headers['Include-Resources'] = resource.try(:include_resources)&.join(',')

    status_code = status_code_for_request(resource)
    Rails.logger.info "Completed #{status_code} #{Rack::Utils::HTTP_STATUS_CODES[status_code]}"

    [status_code, headers, []]
  end

  private

  def default_headers
    return {} if ActsAsTenant.current_tenant.blank?

    {
      'Content-Length' => '0',
      'Content-Type' => 'application/n-quads'
    }
  end

  def language_from_r; end

  def resource_from_request
    return unless ActsAsTenant.current_tenant

    resource_from_iri(request.original_url, ActsAsTenant.current_tenant)
  end

  def prepare_request(env)
    @request = ActionDispatch::Request.new(env)
    @headers = default_headers
  end

  def status_code_for_request(resource)
    actual_iri = resource.try(:iri_path)
    if actual_iri.present? && actual_iri != request.path
      headers['Location'] = resource.iri.to_s
      return 302
    end

    Pundit.policy(user_context, resource).show? ? 200 : 403
  rescue ActiveRecord::RecordNotFound
    404
  end

  def update_oauth_token(token)
    headers['New-Authorization'] = token
  end
end