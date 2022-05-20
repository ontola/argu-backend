# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'linked_rails/emp_json/instrumentation'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'apex'

  c.use 'LinkedRails::EmpJSON::Instrumentation'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::PG', {
    db_statement: :include
  }
  c.use 'OpenTelemetry::Instrumentation::Rack', {
    retain_middleware_names: true,
    application: Rails.application
  }
  c.use 'OpenTelemetry::Instrumentation::Redis'
end

OpenTelemetry.error_handler = lambda do |exception: nil, message: nil|
  received_exception = exception
  received_message = message

  puts(received_exception)
  puts(received_message)
end
