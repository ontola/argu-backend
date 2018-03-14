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
        format.js { update_respond_failure_js(resource) }
        format.json { update_respond_failure_json(resource) }
        format.json_api { update_respond_failure_serializer(resource, :json_api) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { update_respond_failure_serializer(resource, type) }
        end
      end

      # @!visibility public
      def update_respond_blocks_success(resource, format)
        format.html { update_respond_success_html(resource) }
        format.js { update_respond_success_js(resource) }
        format.json { update_respond_success_json(resource) }
        format.json_api { update_respond_success_serializer(resource, :json_api) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { update_respond_success_serializer(resource, type) }
        end
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
      def update_respond_failure_js(resource)
        respond_with_form_js(resource)
      end

      # @!visibility public
      def update_respond_success_js(resource)
        respond_with_redirect_success_js(resource, :save)
      end

      # @!visibility public
      def update_respond_failure_json(resource)
        respond_with_422(resource, :json)
      end

      # @!visibility public
      def update_respond_success_json(resource)
        respond_with_204(resource, :json)
      end

      # @!visibility public
      def update_respond_failure_serializer(resource, format)
        respond_with_422(resource, format)
      end

      # @!visibility public
      def update_respond_success_serializer(resource, format)
        respond_with_204(resource, format)
      end

      # @!visibility public
      def execute_update
        authenticated_resource.update permit_params
      end
    end
  end
end
