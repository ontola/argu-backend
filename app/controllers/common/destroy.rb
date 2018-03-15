# frozen_string_literal: true

module Common
  module Destroy
    extend ActiveSupport::Concern

    included do
      define_action_methods(:destroy)
      define_handlers(:delete)

      def delete
        delete_handler_success(authenticated_resource)
      end

      private

      # @!visibility public
      def delete_respond_blocks_success(resource, format)
        format.html { delete_respond_success_html(resource) }
        format.js { delete_respond_success_js(resource) }
      end

      # @!visibility public
      def delete_respond_success_html(resource)
        render 'delete', locals: {resource: resource}
      end

      # @!visibility public
      def delete_respond_success_js(resource)
        render 'delete.js', layout: false, locals: {template: lookup_template('delete'), resource: resource}
      end

      # @!visibility public
      def destroy_respond_blocks_failure(resource, format)
        format.html { destroy_respond_failure_html(resource) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
        format.js { destroy_respond_failure_js(resource) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { respond_with_422(resource, type) }
        end
      end

      # @!visibility public
      def destroy_respond_blocks_success(resource, format)
        format.html { destroy_respond_success_html(resource) }
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
        format.js { destroy_respond_success_js(resource) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { respond_with_204(resource, type) }
        end
      end

      # @!visibility public
      def destroy_respond_failure_html(resource)
        respond_with_redirect_failure(resource, :destroy)
      end

      # @!visibility public
      def destroy_respond_success_html(resource)
        respond_with_redirect_success(resource, :destroy, status: 303)
      end

      # @!visibility public
      def destroy_respond_failure_js(resource)
        respond_with_400(resource, :js)
      end

      # @!visibility public
      def destroy_respond_success_js(resource)
        respond_with_redirect_success_js(resource, :destroy)
      end

      def execute_destroy
        authenticated_resource.destroy
      end
    end
  end
end
