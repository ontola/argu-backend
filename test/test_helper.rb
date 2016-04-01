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
require 'test_mocks'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

DatabaseCleaner.strategy = :transaction

module TestHelper
  Sidekiq::Testing.fake!
  MiniTest::Reporters.use!

  User.find_or_create_by(id: 0) do |user|
    user.shortname = Shortname.new(shortname: 'community')
    user.email = 'community@argu.co'
    user.first_name = nil
    user.last_name = nil
    user.password = 'password'
    user.finished_intro = true
    user.profile = Profile.new(id: 0)
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

module AuthorizationAssertions
  def assert_not_a_member
    assert_equal true, assigns(:_not_a_member_caught)
    assert_response 403
  end

  def assert_not_a_user
    assert_equal true, assigns(:_not_a_user_caught) || assigns(:_not_logged_in_caught)
  end

  def assert_not_authorized
    assert_equal true, assigns(:_not_authorized_caught)
  end
end

class ActiveSupport::TestCase
  include TestHelper
  include TestMocks
  include AuthorizationAssertions
  ActiveRecord::Migration.check_pending!

  include FactoryGirl::Syntax::Methods
  # FactoryGirl.lint
  Setting.set('user_cap', '-1')
  # Add more helper methods to be used by all tests here...

  def assert_notification_sent
  end

  def change_actor(actor)
    a = actor.respond_to?(:profile) ? actor.profile : actor
    @controller.instance_variable_set(:@_current_actor, a)
  end

  def create_manager(forum, user = nil)
    user ||= create(:user)
    create(:managership, forum: forum, profile: user.profile)
    user
  end

  def create_member(forum, user = nil)
    user ||= create(:user)
    create(:membership, forum: forum, profile: user.profile)
    user
  end

  def create_group_member(group, user_or_page = nil)
    user_or_page ||= create_member(group.forum)
    create(:group_membership,
           group: group,
           member: user_or_page.profile)
    user_or_page
  end

  def create_moderator(record, user = nil)
    user ||= create(:user)
    forum = record.is_a?(Forum) ? record : record.forum
    create(:stepup, forum: forum, record: record, moderator: create_member(forum, user))
    user
  end

  # Makes the given `User` a manager of the `Page` of the `Forum`
  # Creates one if not given
  # @note overwrites the current owner in the `Page`
  def create_owner(forum, user = nil)
    user ||= create(:user)
    forum.page.owner = user.profile
    assert_equal true, forum.page.save, "Couldn't create owner"
    user
  end

  def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
    user = create(:user, manager_opts)
    forum = create((forum_opts[:type] || :forum),
                   page: create(:page,
                                owner: user.profile))
    return forum, user
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include TestMocks
  include AuthorizationAssertions

  def setup_allowed_pages
    Capybara::Webkit.configure do |config|
      config.allow_url 'http://fonts.googleapis.com/css?family=Open+Sans:400italic,400,300,700'
      config.allow_url 'http://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css'
      config.allow_url 'https://www.youtube.com/embed/mxQZNodm8OI'
    end
  end

  def sign_in(user = create(:user))
    post user_session_path,
         user: {
           email: user.email,
           password: user.password
         }
    assert_response 302
  end
end

class FactoryGirl::Evaluator
  def passed_in?(name)
    # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
    # Also check that we didn't pass in nil.
    __override_names__.include?(name) && send(name)
  end
end

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
  end
end

class MiniTest::Spec
  include SidekiqMinitestSupport
end

class MiniTest::Unit::TestCase
  include SidekiqMinitestSupport
end
