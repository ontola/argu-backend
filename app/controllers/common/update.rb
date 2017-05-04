# frozen_string_literal: true
module Common
  module Update
    extend ActiveSupport::Concern

    included do
      define_action_methods(:update)

      private

      # @!visibility public
      def update_respond_blocks_failure(resource, format)
        format.html { update_respond_failure_html(resource) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
      end

      # @!visibility public
      def update_respond_blocks_success(resource, format)
        format.html { update_respond_success_html(resource) }
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
      end

      # @!visibility public
      def update_respond_failure_html(resource)
        respond_with_form(resource)
      end

      # @!visibility public
      def update_respond_success_html(resource)
        respond_with_redirect_success(resource, :save)
      end

      # @!visibility public
      def execute_update
        authenticated_resource.update permit_params
      end
    end
  end
end
