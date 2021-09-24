# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'argu/test_helpers/searchkick_mock'
require 'database_cleaner'
require 'fakeredis/rspec'
require 'sidekiq/testing'
require 'webmock/rspec'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ActsAsTenant::Sidekiq::Server
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    ENV['ELASTICSEARCH_URL']
  ]
)

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Argu::TestHelpers::IriHelpers
  config.include Argu::TestHelpers::TestHelperMethods
  config.include Argu::TestHelpers::RspecHelpers
  config.include Argu::TestHelpers::TestMocks
  config.include Argu::TestHelpers::TestAssertions
  config.include Argu::TestHelpers::RequestHelpers
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

  config.after do
    reset_tenant
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
