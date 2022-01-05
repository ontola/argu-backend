# frozen_string_literal: true

# To enable profiling:
# * Add ENABLE_PROFILING=true to your env
# * Add unicorn-rails to the gemfile
# * Add `?pp=flamegraph` to the url you are visiting
if ENV['ENABLE_PROFILING'] == 'true'
  require 'rack-mini-profiler'

  Rack::MiniProfiler.config.start_hidden = true
  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.authorization_mode = :allow_all
end
