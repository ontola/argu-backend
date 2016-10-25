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
Minitest::Reporters.use!

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

DatabaseCleaner.strategy = :transaction

module TestHelper
  Sidekiq::Testing.fake!
  MiniTest::Reporters.use!

  MiniTest.after_run { FileUtils.rm_rf(Dir["#{Rails.root}/public/photos/[^.]*"]) }

  User.find_or_create_by(id: 0) do |user|
    user.shortname = Shortname.new(shortname: 'community')
    user.email = 'community@argu.co'
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.finished_intro = true
    user.profile = Profile.new(id: 0)
  end

  Page.find_or_create_by(id: 0) do |page|
    page.edge = Edge.new(user: User.find(0))
    page.last_accepted = DateTime.current
    page.profile = Profile.new(name: 'public page profile')
    page.owner = User.find(0).profile
    page.shortname = Shortname.new(shortname: 'public_page')
  end

  Group.find_or_create_by(id: Group::PUBLIC_GROUP_ID) do |group|
    group.edge = Edge.new(user: User.find(0), parent: Page.find(0).edge)
    group.page = Page.find(0)
  end

  if Doorkeeper::Application.find_by(id: 0).blank?
    Doorkeeper::Application.create!(
      id: 0,
      name: 'Argu',
      owner: Profile.find(0),
      redirect_uri: 'http://example.com/'
    )
  end

  # Runs assert_difference with a number of conditions and varying difference
  # counts.
  #
  # @example
  #   assert_differences([['Model1.count', 2], ['Model2.count', 3]])
  #
  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }

    yield

    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end
end

module ActiveSupport
  class TestCase
    include TestHelper
    include FactoryGirl::Syntax::Methods
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::TestMocks
    include Argu::TestHelpers::AutomatedTests
    include Argu::TestHelpers::TestDefinitions
    ActiveRecord::Migration.check_pending!

    # FactoryGirl.lint
    # Add more helper methods to be used by all tests here...

    def initialize(*args)
      super
      analytics_collect
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    include Argu::TestHelpers::TestHelperMethods
    include Argu::TestHelpers::TestMocks

    def setup_allowed_pages
      Capybara::Webkit.configure do |config|
        config.allow_url 'http://fonts.googleapis.com/css?family=Open+Sans:400italic,400,300,700'
        config.allow_url 'http://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css'
        config.allow_url 'https://www.youtube.com/embed/mxQZNodm8OI'
      end
    end

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

    def sign_in(user = create(:user))
      t = Doorkeeper::AccessToken.find_or_create_for(
        Doorkeeper::Application.find(0),
        user.id,
        'user',
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

module FactoryGirl
  class Evaluator
    def passed_in?(name)
      # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
      # Also check that we didn't pass in nil.
      __override_names__.include?(name) && send(name)
    end
  end
end

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
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
