# frozen_string_literal: true
if Rails.env.development? || Rails.env.staging?
  require 'rack-mini-profiler'

  Rack::MiniProfiler.config.start_hidden = true
  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
