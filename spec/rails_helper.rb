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
require 'sidekiq/testing'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each {|f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Capybara::DSL

  Sidekiq::Testing.fake!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

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

  Capybara.register_driver :selenium_firefox do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = true
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox('elementScrollBehavior' => 1)
    Capybara::Selenium::Driver.new(app,
                                   browser: :firefox,
                                   profile: profile,
                                   desired_capabilities: capabilities)
  end

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :selenium_safari do |app|
    Capybara::Selenium::Driver.new(app, browser: :safari)
  end

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {timeout: 30})
  end

  Capybara.default_driver = case ENV['BROWSER']
                            when 'chrome'
                              :selenium_chrome
                            when 'firefox'
                              :selenium_firefox
                            when 'webkit'
                              :webkit
                            when 'ie'
                              :internet_explorer
                            when 'safari'
                              :selenium_safari
                            else
                              ENV['CI'].present? ? :selenium : :selenium
                            end
  #Capybara.default_max_wait_time = 5
  Capybara.default_max_wait_time = 50

  Capybara::Webkit.configure do |config|
    config.allow_url 'http://fonts.googleapis.com/css?family=Open+Sans:400italic,400,300,700'
    config.allow_url 'http://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css'
    config.allow_url '//www.youtube.com/embed/*'
    config.allow_url 'http://example.com/embed/*'
    config.allow_url '//www.gravatar.com/*'
  end

end

class FactoryGirl::Evaluator
  def passed_in?(name)
    # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
    # Also check that we didn't pass in nil.
    __override_names__.include?(name) && send(name)
  end
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1) { retrieve_connection }
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
