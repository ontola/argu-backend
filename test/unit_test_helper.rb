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
require 'minitest/pride'
require 'minitest/reporters'
require 'webmock/minitest'
require 'rspec/matchers'
require 'rspec/expectations'

require 'support/custom_reporter'

Minitest::Reporters.use! unless ENV['RM_INFO']

module TestHelper
  include RSpec::Expectations
  include RSpec::Matchers
  Minitest::Reporters.use! unless ENV['RM_INFO']

  MiniTest.after_run { FileUtils.rm_rf(Rails.root.join('public/photos/[^.]*')) }
end
