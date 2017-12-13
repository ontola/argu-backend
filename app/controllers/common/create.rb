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
        format.json { create_respond_failure_json(resource) }
        format.json_api { respond_with_422(resource, :json_api) }
        format.n3 { respond_with_422(resource, :n3) }
        format.nt { respond_with_422(resource, :nt) }
        format.ttl { respond_with_422(resource, :ttl) }
        format.jsonld { respond_with_422(resource, :jsonld) }
        format.rdf { respond_with_422(resource, :rdf) }
      end

      # @!visibility public
      def create_respond_blocks_success(resource, format)
        format.html { create_respond_success_html(resource) }
        format.js { create_respond_success_js(resource) }
        format.json { create_respond_success_json(resource) }
        format.json_api { respond_with_201(resource, :json_api) }
        format.n3 { respond_with_201(resource, :n3) }
        format.nt { respond_with_201(resource, :nt) }
        format.ttl { respond_with_201(resource, :ttl) }
        format.jsonld { respond_with_201(resource, :jsonld) }
        format.rdf { respond_with_201(resource, :rdf) }
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
      def create_respond_failure_json(resource)
        respond_with_422(resource, :json)
      end

      # @!visibility public
      def create_respond_success_json(resource)
        respond_with_201(resource, :json)
      end

      # @!visibility public
      def execute_create
        authenticated_resource.save
      end
    end
  end
end
