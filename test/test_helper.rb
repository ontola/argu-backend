# frozen_string_literal: true

require 'unit_test_helper'

require 'sidekiq/testing'
require 'argu/test_helpers/searchkick_mock'
require 'support/database_cleaner'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ActsAsTenant::Sidekiq::Server
end

DatabaseCleaner.strategy = :transaction
WebMock.disable_net_connect!(
  allow: [
    ENV['ELASTICSEARCH_URL']
  ]
)

module SidekiqMinitestSupport
  def teardown
    mail_workers = Sidekiq::Worker.jobs.select { |j| j['class'] == 'SendEmailWorker' }
    Sidekiq::Worker.clear_all

    assert_equal(
      0,
      mail_workers.count,
      "Found #{mail_workers.count} unexpected mail(s): #{mail_workers.map { |opts| opts['args'].first }}"
    )
  end
end

module ActiveSupport
  class TestCase
    include TestHelper
    include FactoryBot::Syntax::Methods
    include SidekiqMinitestSupport
    include Argu::TestHelpers::IRIHelpers
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::SliceHelperMethods
    include Argu::TestHelpers::TestMocks
    include Argu::TestHelpers::TestDefinitions
    include Argu::TestHelpers::TestAssertions
    include Argu::TestHelpers::RequestHelpers
    include UrlHelper
    ActiveRecord::Migration.check_pending!

    setup do
      I18n.locale = :en
    end

    teardown do
      keys = Argu::Redis.keys('temporary*')
      Argu::Redis.redis_instance.del(*keys) if keys.present?
      reset_tenant
    end

    before do
      mapbox_mock
      Argu::Redis.set(Argu::OAuth::REDIS_CLIENT_KEY, {token: sign_payload({scopes: %w[service]})}.to_json)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Argu::TestHelpers::IRIHelpers
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::SliceHelperMethods
    include Argu::TestHelpers::TestMocks
    include SidekiqMinitestSupport

    setup do
      I18n.locale = :en
      self.host = Rails.application.config.host_name
    end

    teardown do
      reset_tenant
    end

    before do
      Argu::Redis.set(Argu::OAuth::REDIS_CLIENT_KEY, {token: sign_payload({scopes: %w[service]})}.to_json)
    end

    def follow_redirect!
      raise "not a redirect! #{status} #{status_message}" unless redirect?

      get(response.location)
      process_new_authorization
      status
    end

    def head(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def get(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def post(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def delete(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def process_new_authorization(result = nil)
      new_token = client_token_from_response
      sign_in new_token if new_token
      result
    end

    def patch(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def put(path, **opts)
      process_new_authorization(
        super(
          path.try(:iri)&.path || path,
          **merge_req_opts(**opts)
          )
      )
    end

    def sign_in(resource = create(:user))
      token = resource.is_a?(String) ? resource : doorkeeper_token_for(resource).token
      @_argu_headers = (@_argu_headers || {}).merge(argu_headers(bearer: token))
    end

    private

    def merge_req_opts(**opts)
      opts.merge(headers: (@_argu_headers || {}).merge(opts[:headers] || {}))
    end
  end
end

module ActionController
  class TestCase
    setup do
      I18n.locale = :en
      request.host = Rails.application.config.host_name
    end

    before do
      ActsAsTenant.current_tenant = argu
    end

    teardown do
      reset_tenant
    end
  end
end

module ActionDispatch
  module Integration
    module RequestHelpers
      def options(path, **args)
        process(:options, path, **args)
      end
    end
  end
end

module FactoryBot
  class Evaluator
    def passed_in?(name)
      # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
      # Also check that we didn't pass in nil.
      __override_names__.include?(name) && send(name)
    end
  end
end

module MiniTest
  class Spec
    include SidekiqMinitestSupport
  end
end

module MiniTest
  class Unit
    class TestCase
      include SidekiqMinitestSupport
    end
  end
end
