# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Instrument
      extend ActiveSupport::Concern

      included do
        alias_method :plain_render_emp_json, :render_emp_json
        alias_method :render_emp_json, :instrumented_render_emp_json

        alias_method :plain_emp_json_hash, :emp_json_hash
        alias_method :emp_json_hash, :instrumented_emp_json_hash
      end

      def instrumented_render_emp_json
        tracer.in_span('render_emp_json', kind: :internal, attributes: build_attributes) do
          plain_render_emp_json
        end
      end

      def instrumented_emp_json_hash
        tracer.in_span('emp_json_hash', kind: :internal, attributes: build_attributes) do
          plain_emp_json_hash
        end
      end

      def build_attributes
        {
          'serializer.name': self.class.name.to_s,
          'serializer.resource.class': @resource.class.name,
          'serializer.user_type': user_type
        }
      end

      def tracer
        LinkedRails::EmpJSON::Instrumentation.instance.tracer
      end

      def user_type
        id = @params[:scope].user&.id
        case id
        when User::COMMUNITY_ID
          'community'
        when User::SERVICE_ID
          'service'
        when User::ANONYMOUS_ID
          'anonymous'
        when User::GUEST_ID
          'guest'
        else
          'registered user'
        end
      end
    end
  end
end

module LinkedRails
  module EmpJSON
    class Instrumentation < OpenTelemetry::Instrumentation::Base
      install do |_config|
        require_dependencies
        wrap_render_method
      end

      present do
        !defined?(::LinkedRails::EmpJSON).nil?
      end

      compatible do
        true
      end

      private

      def require_dependencies; end

      def wrap_render_method
        # BaseSerializer.include(LinkedRails::EmpJSON::Instrument)
        # BaseSerializer.extend(LinkedRails::EmpJSON::Instrument)
        # BaseSerializer.prepend(LinkedRails::EmpJSON::Instrument)
      end
    end
  end
end
