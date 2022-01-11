# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/minitest'
require 'model_test_base'
require 'wisper/minitest/assertions'
require 'simplecov'
require 'fakeredis'
require 'sidekiq/testing'
require 'minitest/pride'
require 'minitest/reporters'
require 'webmock/minitest'
require 'rspec/matchers'
require 'rspec/expectations'

require 'support/custom_reporter'
require 'argu/test_helpers/searchkick_mock'
require 'support/database_cleaner'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ActsAsTenant::Sidekiq::Server
end

Minitest::Reporters.use! unless ENV['RM_INFO']

DatabaseCleaner.strategy = :transaction
WebMock.disable_net_connect!(
  allow: [
    ENV['ELASTICSEARCH_URL']
  ]
)

module TestHelper
  include RSpec::Expectations
  include RSpec::Matchers
  Sidekiq::Testing.fake!
  Minitest::Reporters.use! unless ENV['RM_INFO']

  MiniTest.after_run { FileUtils.rm_rf(Rails.root.join('public/photos/[^.]*')) }
end

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
    super
  end
end

module ActiveSupport
  class TestCase
    include TestHelper
    include FactoryBot::Syntax::Methods
    include SidekiqMinitestSupport
    include Argu::TestHelpers::IRIHelpers
    include Argu::TestHelpers::TestHelperMethods
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

    # FactoryBot.lint
    # Add more helper methods to be used by all tests here...

    def initialize(*args)
      super
      mapbox_mock
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Argu::TestHelpers::IRIHelpers
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::TestMocks
    include SidekiqMinitestSupport

    setup do
      I18n.locale = :en
      self.host = Rails.application.config.host_name
    end

    teardown do
      reset_tenant
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
