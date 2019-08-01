# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/mini_test'
require 'model_test_base'
require 'capybara/rails'
require 'wisper/minitest/assertions'
require 'simplecov'
require 'fakeredis'
require 'sidekiq/testing'
require 'minitest/pride'
require 'minitest/reporters'
require 'webmock/minitest'
require 'argu/test_helpers'
require 'minitest/reporters'
require 'rspec/matchers'
require 'rspec/expectations'

require 'support/database_cleaner'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ActsAsTenant::Sidekiq::Server
end

Minitest::Reporters.use!

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

DatabaseCleaner.strategy = :transaction
WebMock.disable_net_connect!(
  allow: [
    "https://#{Rails.application.config.rakismet[:key]}.rest.akismet.com",
    'http://localhost:9200'
  ]
)

module TestHelper
  include RSpec::Expectations
  include RSpec::Matchers
  Sidekiq::Testing.fake!
  MiniTest::Reporters.use!

  MiniTest.after_run { FileUtils.rm_rf(Rails.root.join('public', 'photos', '[^.]*')) }
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
    include Argu::TestHelpers::IriHelpers
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
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    include Argu::TestHelpers::IriHelpers
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
      status
    end

    def get(path, *args, **opts)
      super(
        path.try(:iri)&.path || path,
        *args,
        merge_req_opts(opts)
        )
    end

    def post(path, *args, **opts)
      super(
        path.try(:iri)&.path || path,
        *args,
        merge_req_opts(opts)
        )
    end

    def delete(path, *args, **opts)
      super(
        path.try(:iri)&.path || path,
        *args,
        merge_req_opts(opts)
        )
    end

    def patch(path, *args, **opts)
      super(
        path.try(:iri)&.path || path,
        *args,
        merge_req_opts(opts)
        )
    end

    def put(path, *args, **opts)
      super(
        path.try(:iri)&.path || path,
        *args,
        merge_req_opts(opts)
        )
    end

    # rubocop:disable Metrics/AbcSize
    def sign_in(resource = create(:user), requested_app = Doorkeeper::Application.argu)
      additional_scope = requested_app.id == Doorkeeper::Application::AFE_ID && 'afe'
      id, role, app =
        case resource
        when :service
          [User::SERVICE_ID, 'afe service', Doorkeeper::Application.argu_service]
        when GuestUser
          [resource.id, ['guest', additional_scope].join(' '), requested_app]
        else
          [resource.id, ['user', additional_scope].join(' '), requested_app]
        end
      t = Doorkeeper::AccessToken.new(application: app, resource_owner_id: id, scopes: role, expires_in: 10.minutes)
      if resource.is_a?(GuestUser)
        t.send(:generate_token)
      else
        t.save!
      end
      @_argu_headers = (@_argu_headers || {}).merge(argu_headers(bearer: t.token))
    end
    # rubocop:enable Metrics/AbcSize
    alias log_in_user sign_in
    deprecate :log_in_user

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
      def options(path, args = {})
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
