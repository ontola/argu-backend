# frozen_string_literal: true

module Common
  module Edit
    extend ActiveSupport::Concern

    included do
      define_handlers(:edit)

      def edit
        edit_handler_success(authenticated_resource!)
      end

      private

      # @!visibility public
      def edit_respond_blocks_success(resource, format)
        format.html { edit_respond_success_html(resource) }
        format.json { respond_with_200(resource, :json) }
        format.json_api { respond_with_200(resource, :json_api) }
        format.js { edit_respond_success_js(resource) }
        format.n3 { respond_with_200(resource, :n3) }
        format.nt { respond_with_200(resource, :nt) }
        format.ttl { respond_with_200(resource, :ttl) }
        format.jsonld { respond_with_200(resource, :jsonld) }
        format.rdf { respond_with_200(resource, :rdf) }
      end

      # @!visibility public
      def edit_respond_success_html(resource)
        respond_with_form(resource)
      end

      # @!visibility public
      def edit_respond_success_js(_)
        render
      end
    end
  end
end
