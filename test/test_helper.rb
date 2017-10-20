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

module TestHelper
  include RSpec::Expectations
  include RSpec::Matchers
  Sidekiq::Testing.fake!
  MiniTest::Reporters.use!

  MiniTest.after_run { FileUtils.rm_rf(Rails.root.join('public', 'photos', '[^.]*')) }

  User.find_or_create_by(id: User::COMMUNITY_ID) do |user|
    user.shortname = Shortname.new(shortname: 'community')
    user.email = 'community@argu.co'
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.profile = Profile.new(id: Profile::COMMUNITY_ID)
  end

  Page.find_or_create_by(id: 0) do |page|
    page.edge = Edge.new(user: User.community)
    page.last_accepted = DateTime.current
    page.profile = Profile.new(name: 'public page profile')
    page.owner = User.create!(
      shortname: Shortname.new(shortname: 'page_owner'),
      profile: Profile.new,
      email: 'page_owner@argu.co'
    ).profile
    page.shortname = Shortname.new(shortname: 'public_page')
  end

  public_group = Group.find_or_create_by(id: Group::PUBLIC_ID) do |group|
    group.name = 'Public group'
    group.name_singular = 'User'
    group.page = Page.find(0)
  end

  Group.find_or_create_by(id: Group::STAFF_ID) do |group|
    group.name = 'Staff group'
    group.name_singular = 'Staff'
    group.page = Page.find(0)
  end

  public_membership =
    CreateGroupMembership.new(
      public_group,
      attributes: {member: Profile.community},
      options: {publisher: User.community, creator: Profile.community}
    ).resource
  public_membership.save(validate: false)

  if Doorkeeper::Application.find_by(id: Doorkeeper::Application::ARGU_ID).blank?
    Doorkeeper::Application.create!(
      id: Doorkeeper::Application::ARGU_ID,
      name: 'Argu',
      owner: Profile.community,
      redirect_uri: 'http://example.com/'
    )
  end
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
    include FactoryGirl::Syntax::Methods
    include SidekiqMinitestSupport
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::TestMocks
    include Argu::TestHelpers::AutomatedTests
    include Argu::TestHelpers::TestDefinitions
    include Argu::TestHelpers::TestAssertions
    include Argu::TestHelpers::RequestHelpers
    include UrlHelper
    ActiveRecord::Migration.check_pending!

    teardown do
      keys = Argu::Redis.keys('temporary*')
      Argu::Redis.redis_instance.del(*keys) if keys.present?
    end

    # FactoryGirl.lint
    # Add more helper methods to be used by all tests here...

    def initialize(*args)
      super
      analytics_collect
      mapbox_mock
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::TestMocks
    include SidekiqMinitestSupport

    def get(path, *args, **opts)
      super(
        path,
        *args,
        merge_req_opts(opts)
        )
    end

    def post(path, *args, **opts)
      super(
        path,
        *args,
        merge_req_opts(opts)
        )
    end

    def delete(path, *args, **opts)
      super(
        path,
        *args,
        merge_req_opts(opts)
        )
    end

    def patch(path, *args, **opts)
      super(
        path,
        *args,
        merge_req_opts(opts)
        )
    end

    def put(path, *args, **opts)
      super(
        path,
        *args,
        merge_req_opts(opts)
        )
    end

    def sign_in(resource = create(:user))
      id, role =
        case resource
        when :service
          [0, 'service']
        when :guest
          [SecureRandom.hex, 'guest']
        else
          [resource.id, 'user']
        end
      t = Doorkeeper::AccessToken.find_or_create_for(
        Doorkeeper::Application.argu,
        id,
        role,
        10.minutes,
        false
      )
      @_argu_headers = (@_argu_headers || {}).merge(
        'Authorization': "Bearer #{t.token}"
      )
    end
    alias log_in_user sign_in
    deprecate :log_in_user

    private

    def merge_req_opts(**opts)
      opts.merge(headers: (@_argu_headers || {}).merge(opts[:headers] || {}))
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

module FactoryGirl
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
