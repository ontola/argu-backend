ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/mini_test'
require 'model_test_base'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require 'minitest/pride'


class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  include FactoryGirl::Syntax::Methods
  #FactoryGirl.lint
  # Add more helper methods to be used by all tests here...

  # Runs assert_difference with a number of conditions and varying difference
  # counts.
  #
  # Call as follows:
  #
  # assert_differences([['Model1.count', 2], ['Model2.count', 3]])
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

  def create_manager(forum, user = nil)
    user ||= FactoryGirl.create(:user)
    FactoryGirl.create(:managership, forum: forum, profile: user.profile)
    user
  end

  def create_member(forum, user = nil)
    user ||= FactoryGirl.create(:user)
    FactoryGirl.create(:membership, forum: forum, profile: user.profile)
    user
  end

  # Makes the given `User` a manager of the `Page` of the `Forum`
  # Creates one if not given
  # @note overwrites the current owner in the `Page`
  def create_owner(forum, user = nil)
    user ||= FactoryGirl.create(:user)
    forum.page.owner = user.profile
    forum.page.save
    user
  end

  def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
    user = FactoryGirl.create(:user, manager_opts)
    forum = FactoryGirl.create((forum_opts[:type] || :forum),
                               page: FactoryGirl.create(:page,
                                                        owner: user.profile))
    return forum, user
  end

end
