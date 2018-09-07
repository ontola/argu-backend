# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rails'
require 'database_cleaner'
require 'fakeredis/rspec'
require 'sidekiq/testing'
require 'webmock/rspec'
require 'argu/test_helpers'
require 'argu/test_helpers/fixes'
require 'argu/test_helpers/rspec_helpers'

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.server_port = 42_000
Capybara.always_include_port = true

module BrowserWrapper
  def press_key(code)
    find('body').native.send_keys code
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Capybara::DSL
  config.include Argu::TestHelpers::Fixes
  config.include Argu::TestHelpers::TestHelperMethods
  config.include Argu::TestHelpers::RspecHelpers
  config.include Argu::TestHelpers::TestMocks
  config.include Argu::TestHelpers::TestAssertions
  config.include Argu::TestHelpers::RequestHelpers
  config.include BrowserWrapper
  config.include UriTemplateHelper
  config.include UrlHelper
  config.include ActiveSupport::Testing::Assertions

  Sidekiq::Testing.fake!

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.before(:each) do
    mapbox_mock
  end

  Capybara.register_driver :selenium_firefox do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 200
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox('elementScrollBehavior' => 1)
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_preference('intl.accept_languages', 'en-US')
    options.add_preference('webdriver_enable_native_events', true)
    Capybara::Selenium::Driver.new(app,
                                   options: options,
                                   browser: :firefox,
                                   http_client: client,
                                   desired_capabilities: capabilities)
  end

  Capybara.register_driver :selenium_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome('elementScrollBehavior' => 1)
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 90
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_preference('intl.accept_languages', 'en-US')
    Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   options: options,
                                   http_client: client,
                                   desired_capabilities: capabilities)
  end

  Capybara.register_driver :selenium_safari do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 90
    Capybara::Selenium::Driver.new(app,
                                   browser: :safari,
                                   http_client: client)
  end

  Capybara.default_driver =
    case ENV['BROWSER']
    when 'chrome'
      :selenium_chrome
    when 'firefox'
      :selenium_firefox
    when 'ie'
      :internet_explorer
    when 'safari'
      :selenium_safari
    else
      ENV['CI'].present? ? :selenium : :selenium_firefox
    end
  # Capybara.default_max_wait_time = 5
  Capybara.default_max_wait_time = 10
  Capybara.exact = true

  unless ENV['RSPEC_TRANSACTION']
    config.before(:each) do
      load(Dir[Rails.root.join('db', 'seeds', 'grant_sets.seeds.rb')][0]) if GrantSet.count == 0
      {Group => %w[public staff], User => %w[anonymous community], Profile => %w[anonymous community]}.each do |k, v|
        v.each { |var| k.instance_variable_set("@#{var}", nil) }
      end
      if User.find_by(id: User::COMMUNITY_ID).blank?
        create(:user,
               id: User::COMMUNITY_ID,
               shortname: build(:shortname, shortname: 'community'),
               email: 'community@argu.co',
               password: 'password',
               first_name: nil,
               last_name: nil,
               profile: build(:profile, id: Profile::COMMUNITY_ID))
      end
      if User.find_by(id: User::ANONYMOUS_ID).blank?
        create(:user,
               id: User::ANONYMOUS_ID,
               shortname: build(:shortname, shortname: 'anonymous'),
               email: 'anonymous@argu.co',
               password: 'password',
               first_name: nil,
               last_name: nil,
               profile: build(:profile, id: Profile::ANONYMOUS_ID))
      end
      if User.find_by(id: User::SERVICE_ID).blank?
        create(:user,
               id: User::SERVICE_ID,
               shortname: build(:shortname, shortname: 'service'),
               email: 'service_user@argu.co',
               password: 'password',
               last_accepted: Time.current,
               first_name: nil,
               last_name: nil,
               profile: build(:profile, id: Profile::SERVICE_ID))
      end
      if Page.find_by(id: Profile::COMMUNITY_ID).blank?
        page_owner = User.create!(
          shortname: Shortname.new(shortname: 'page_owner'),
          profile: Profile.new,
          email: 'page_owner@argu.co'
        )
        create(
          :page,
          id: 0,
          last_accepted: Time.current,
          profile: Profile.new(name: 'public page profile'),
          creator: page_owner.profile,
          publisher: page_owner,
          shortname: Shortname.new(shortname: 'public_page')
        )
      end
      if Group.find_by(id: Group::PUBLIC_ID).blank?
        g = create(:group, id: Group::PUBLIC_ID, parent: Page.find(0), name: 'Public group', name_singular: 'User')
        public_membership =
          CreateGroupMembership.new(
            g,
            attributes: {member: Profile.community},
            options: {publisher: User.community, creator: Profile.community}
          ).resource
        public_membership.save(validate: false)
      end
      if Group.find_by(id: Group::STAFF_ID).blank?
        create(:group, id: Group::STAFF_ID, parent: Page.find(0), name: 'Staff group', name_singular: 'Staff')
      end
      if Doorkeeper::Application.find_by(id: Doorkeeper::Application::ARGU_ID).blank?
        Doorkeeper::Application.create!(
          id: Doorkeeper::Application::ARGU_ID,
          name: 'Argu',
          owner: Profile.community,
          redirect_uri: 'http://example.com/',
          scopes: 'guest user'
        )
      end
      if Doorkeeper::Application.find_by(id: Doorkeeper::Application::AFE_ID).blank?
        Doorkeeper::Application.create!(
          id: Doorkeeper::Application::AFE_ID,
          name: 'Argu Front End',
          owner: Profile.community,
          redirect_uri: 'http://example.com/',
          scopes: 'guest user afe'
        )
      end
      if Doorkeeper::Application.find_by(id: Doorkeeper::Application::SERVICE_ID).blank?
        Doorkeeper::Application.create!(
          id: Doorkeeper::Application::SERVICE_ID,
          name: 'Argu Service',
          owner: Profile.community,
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scopes: 'service worker export'
        )
      end
    end
  end

  OmniAuth.config.test_mode = true
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

module ActionDispatch
  module Assertions
    module ResponseAssertions
      def normalize_argument_to_redirection(fragment)
        case fragment
        when %r{\A([a-z][a-z\d\-+\.]*:|\/\/).*}i
          fragment
        when String
          @request.protocol + Rails.application.config.host_name + fragment
        else
          super
        end
      end
    end
  end
end
