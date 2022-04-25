# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Ensure logging works during initialization
if !Rails.env.test? && (Rails.env.development? || ENV['RAILS_LOG_TO_STDOUT'].present?)
  Rails.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
end

# Initialize the Rails application.
Rails.application.initialize!

STAGES = %i[production staging].freeze
