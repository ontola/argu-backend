# frozen_string_literal: true

module Common
  module Create
    extend ActiveSupport::Concern

    included do
      define_action_methods(:create)

      private

      # @!visibility public
      def create_respond_blocks_failure(resource, format)
        format.html { create_respond_failure_html(resource) }
        format.js { create_respond_failure_js(resource) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
      end

      # @!visibility public
      def create_respond_blocks_success(resource, format)
        format.html { create_respond_success_html(resource) }
        format.js { create_respond_success_js(resource) }
        format.json { respond_with_201(resource, :json) }
        format.json_api { respond_with_201(resource, :json_api) }
      end

      # @!visibility public
      def create_respond_failure_html(resource)
        respond_with_form(resource)
      end

      # @!visibility public
      def create_respond_success_html(resource)
        respond_with_redirect_success(resource, :save)
      end

      # @!visibility public
      def create_respond_failure_js(resource)
        respond_with_form_js(resource)
      end

      # @!visibility public
      def create_respond_success_js(resource)
        respond_with_redirect_success_js(resource, :create)
      end

      # @!visibility public
      def execute_create
        authenticated_resource.save
      end
    end
  end
end
