# frozen_string_literal: true
module Common
  module Destroy
    extend ActiveSupport::Concern

    included do
      define_action_methods(:destroy)

      private

      # @!visibility public
      def destroy_respond_blocks_failure(resource, format)
        format.html { destroy_respond_failure_html(resource) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
        format.js { destroy_respond_failure_js(resource) }
      end

      # @!visibility public
      def destroy_respond_blocks_success(resource, format)
        format.html { destroy_respond_success_html(resource) }
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
        format.js { destroy_respond_success_js(resource) }
      end

      # @!visibility public
      def destroy_respond_failure_html(resource)
        respond_with_redirect_failure(resource, :destroy)
      end

      # @!visibility public
      def destroy_respond_success_html(resource)
        respond_with_redirect_success(resource, :destroy)
      end

      # @!visibility public
      def destroy_respond_failure_js(resource)
        respond_with_400(resource, :js)
      end

      # @!visibility public
      def destroy_respond_success_js(_)
        render
      end

      def execute_destroy
        authenticated_resource.destroy
      end
    end
  end
end
