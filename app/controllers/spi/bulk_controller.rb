# frozen_string_literal: true

require 'benchmark'

module SPI
  # rubocop:disable Metrics/ClassLength
  class BulkController < SPI::SPIController
    include NestedResourceHelper
    skip_after_action :verify_authorized

    def show
      @timings = []
      resources = authorized_resources
      print_timings
      render json: resources
    end

    private

    def authorize_action; end

    def authorized_resource(opts) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      return response_for_wrong_host(opts[:iri]) if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'
      resource = LinkedRails.resource_from_iri(path_to_url(opts[:iri]))

      return response_from_request(include, RDF::URI(opts[:iri])) unless resource.try(:cacheable?)

      response_from_resource(include, resource)
    rescue StandardError => e
      Bugsnag.notify(e)
      unless Rails.env.production?
        Rails.logger.error(e)
        Rails.logger.error(e.backtrace.join("\n"))
      end

      resource_response(opts[:iri], status: 500)
    end

    def authorized_resources
      @authorized_resources ||=
        params
          .require(:resources)
          .map { |param| param.permit(:include, :iri) }
          .map(&method(:timed_authorized_resource))
    end

    def print_timings
      Rails.logger.debug(
        "\n  CPU        system     user+system real        inc   status  cache   iri\n" \
        "#{@timings.join("\n")}\n" \
        "  User: #{current_user.class}(#{current_user.id})"
      )
    end

    def require_doorkeeper_token?
      false
    end

    def resource_request(iri) # rubocop:disable Metrics/AbcSize
      path = LinkedRails.iri_mapper_class.send(:sanitized_relative, iri.dup, ActsAsTenant.current_tenant)
      fullpath = iri.query.blank? ? iri.path : "#{iri.path}?#{iri.query}"
      env = Rack::MockRequest.env_for(path, resource_request_headers.merge('ORIGINAL_FULLPATH' => fullpath))
      req = ActionDispatch::Request.new(env)
      req.path_info = ActionDispatch::Journey::Router::Utils.normalize_path(req.path_info)
      req.env['User-Context'] = user_context
      req.env['Current-User'] = current_user
      req.env['Doorkeeper-Token'] = doorkeeper_token

      req
    end

    def resource_request_headers # rubocop:disable Metrics/MethodLength
      req_headers = request.env
      {
        'HTTP_ACCEPT' => 'application/hex+x-ndjson',
        'HTTP_ACCEPT_LANGUAGE' => req_headers['HTTP_ACCEPT_LANGUAGE'],
        'HTTP_AUTHORIZATION' => req_headers['HTTP_AUTHORIZATION'],
        'HTTP_FORWARDED' => req_headers['HTTP_FORWARDED'],
        'HTTP_HOST' => req_headers['HTTP_HOST'],
        'HTTP_OPERATOR_ARG_GRAPH' => 'true',
        'HTTP_X_DEVICE_ID' => req_headers['HTTP_X_DEVICE_ID'],
        'HTTP_X_FORWARDED_FOR' => req_headers['HTTP_X_FORWARDED_FOR'],
        'HTTP_X_FORWARDED_HOST' => req_headers['HTTP_X_FORWARDED_HOST'],
        'HTTP_X_FORWARDED_PROTO' => req_headers['HTTP_X_FORWARDED_PROTO'],
        'HTTP_X_FORWARDED_SSL' => req_headers['HTTP_X_FORWARDED_SSL'],
        'HTTP_X_REAL_IP' => req_headers['HTTP_X_REAL_IP'],
        'HTTP_WEBSITE_IRI' => req_headers['HTTP_WEBSITE_IRI']
      }
    end

    def response_from_request(include, iri)
      status, headers, rack_body = Rails.application.routes.router.serve(resource_request(iri))

      resource_response(
        iri.to_s,
        body: include ? rack_body.body : nil,
        cache: headers['Cache-Control']&.squish&.presence || :private,
        language: response_language(headers),
        status: status
      )
    end

    def response_from_resource(include, resource)
      resource_policy = policy(resource)
      status = resource_status(resource, resource_policy)

      resource_response(
        resource.iri,
        body: include && status == 200 ? resource_body(resource) : nil,
        cache: resource_cache_control(status, resource_policy),
        language: I18n.locale,
        status: status
      )
    end

    def response_for_wrong_host(iri)
      resource_response(iri)
    end

    def resource_response(iri, **opts)
      {
        body: nil,
        cache: :private,
        iri: iri,
        status: 404
      }.merge(opts)
    end

    def resource_body(resource)
      return if resource.nil?

      RDF::Serializers.serializer_for(resource)
        .new(resource,
             include: resource&.class.try(:preview_includes),
             params: {
               scope: user_context,
               context: resource&.try(:iri)
             })
        .send(:render_hndjson)
    end

    def resource_cache_control(status, resource_policy)
      return :private unless status == 200
      return 'no-cache' unless resource_policy.granted_group_ids(:show).include?(Group::PUBLIC_ID)

      :public
    end

    def resource_status(resource, resource_policy)
      return 404 if resource.nil?

      resource_policy.show? ? 200 : 403
    end

    def response_language(headers)
      headers['Content-Language'] || I18n.locale
    end

    def timed_authorized_resource(resource)
      res = nil
      time = Benchmark.measure { res = authorized_resource(resource) }
      unless Rails.env.production?
        include = resource[:include].to_s.ljust(5)
        @timings << "#{time.to_s[0..-2]} - #{include}  #{res[:status]}   #{res[:cache]} #{resource[:iri]}"
      end
      res
    end

    def wrong_host?(iri)
      URI.parse(iri).path != '/ns/core' && !iri.starts_with?(ActsAsTenant.current_tenant.iri)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
