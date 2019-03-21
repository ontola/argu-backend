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
Minitest::Reporters.use!

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

DatabaseCleaner.strategy = :transaction
WebMock.disable_net_connect!(
  allow: "https://#{Rails.application.config.rakismet[:key]}.rest.akismet.com"
)

Searchkick.disable_callbacks

module TestHelper
  include RSpec::Expectations
  include RSpec::Matchers
  Sidekiq::Testing.fake!
  MiniTest::Reporters.use!

  MiniTest.after_run { FileUtils.rm_rf(Rails.root.join('public', 'photos', '[^.]*')) }

  Grant.delete_all
  GrantSetsPermittedAction.delete_all
  PermittedAction.delete_all
  GrantSet.delete_all
  load(Dir[Rails.root.join('db', 'seeds', 'grant_sets.seeds.rb')][0])

  User.find_or_create_by!(id: User::COMMUNITY_ID) do |user|
    user.shortname = Shortname.new(shortname: 'community')
    user.email = 'community@argu.co'
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.profile = Profile.new(id: Profile::COMMUNITY_ID)
  end

  User.find_or_create_by!(id: User::ANONYMOUS_ID) do |user|
    user.shortname = Shortname.new(shortname: 'anonymous')
    user.email = 'anonymous@argu.co'
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.profile = Profile.new(id: Profile::ANONYMOUS_ID)
  end

  User.find_or_create_by!(id: User::SERVICE_ID) do |user|
    user.shortname = Shortname.new(shortname: 'service')
    user.email = 'service_user@argu.co'
    user.last_accepted = Time.current
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.profile = Profile.new(id: Profile::SERVICE_ID)
  end

  page_owner = User.find_or_create_by!(first_name: 'page_owner') do |user|
    user.shortname = Shortname.new(shortname: 'page_owner')
    user.profile = Profile.new
    user.email = 'page_owner@argu.co'
  end

  Page.find_or_create_by!(owner_id: 0) do |page|
    page.publisher = page_owner
    page.creator = page_owner.profile
    page.url = 'public_page'
    page.last_accepted = Time.current
    page.profile = Profile.new(name: 'public page profile')
    page.iri_prefix = "app.#{Rails.application.config.host_name}/public_page"
  end

  public_group = Group.find_or_create_by!(id: Group::PUBLIC_ID) do |group|
    group.name = 'Public group'
    group.name_singular = 'User'
    group.page = Page.find_by(owner_id: 0)
  end

  Group.find_or_create_by!(id: Group::STAFF_ID) do |group|
    group.name = 'Staff group'
    group.name_singular = 'Staff'
    group.page = Page.find_by(owner_id: 0)
  end

  public_membership =
    CreateGroupMembership.new(
      public_group,
      attributes: {member: Profile.community},
      options: {publisher: User.community, creator: Profile.community}
    ).resource
  public_membership.save!(validate: false)

  door_app = Doorkeeper::Application
  door_app.find_or_create_by(id: door_app::ARGU_ID) do |app|
    app.id = door_app::ARGU_ID
    app.name = 'Argu'
    app.owner = Profile.community
    app.redirect_uri = 'http://example.com/'
    app.scopes = 'guest user'
  end
  door_app.find_or_create_by(id: door_app::AFE_ID) do |app|
    app.id = door_app::AFE_ID
    app.name = 'Argu Front End'
    app.owner = Profile.community
    app.redirect_uri = 'http://example.com/'
    app.scopes = 'guest user afe'
  end
  door_app.find_or_create_by(id: door_app::SERVICE_ID) do |app|
    app.id = door_app::SERVICE_ID
    app.name = 'Argu Service'
    app.owner = Profile.community
    app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    app.scopes = 'service worker export'
  end
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{door_app.table_name}_id_seq RESTART WITH #{door_app.count}")
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

    def argu_headers(accept: nil, bearer: nil, host: nil)
      headers = {}
      if accept
        headers['Accept'] = accept.is_a?(Symbol) ? Mime::Type.lookup_by_extension(accept).to_s : accept
      end
      headers['Authorization'] = "Bearer #{bearer}" if bearer
      headers['HTTP_HOST'] = host if host
      headers
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
      t = Doorkeeper::AccessToken.find_or_create_for(
        app,
        id,
        role,
        10.minutes,
        false
      )
      @_argu_headers = (@_argu_headers || {}).merge(argu_headers(bearer: t.token))
    end
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
