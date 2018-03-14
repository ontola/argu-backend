# frozen_string_literal: true

module Common
  module New
    extend ActiveSupport::Concern

    included do
      define_handlers(:new)

      def new
        new_handler_success(authenticated_resource)
      end

      private

      # @!visibility public
      def new_respond_blocks_success(resource, format)
        format.html { new_respond_success_html(resource) }
        format.js { new_respond_success_js(resource) }
        format.json { respond_with_200(resource, :json) }
        format.json_api { respond_with_200(resource, :json_api) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { respond_with_200(resource, type) }
        end
      end

      # @!visibility public
      def new_respond_success_html(resource)
        respond_with_form(resource)
      end

      # @!visibility public
      def new_respond_success_js(_resource)
        render js: "window.location = #{request.url.to_json}"
      end
    end
  end
end
