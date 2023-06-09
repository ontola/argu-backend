# frozen_string_literal: true

unless Rails.env.test? || ENV['DISABLE_PROMETHEUS']
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/metric'
  require 'prometheus_exporter/instrumentation'

  PrometheusExporter::Metric::Base.default_prefix = 'apex'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware

  PrometheusExporter::Instrumentation::ActiveRecord.start(
    custom_labels: {type: 'apex'},
    config_labels: %i[database host]
  )

  PrometheusExporter::Instrumentation::Process.start(type: 'apex')

  Sidekiq.configure_server do |config|
    require 'prometheus_exporter/instrumentation'
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
    config.on :startup do
      PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
      PrometheusExporter::Instrumentation::SidekiqProcess.start
      PrometheusExporter::Instrumentation::SidekiqQueue.start
      PrometheusExporter::Instrumentation::SidekiqStats.start
    end
  end
end
