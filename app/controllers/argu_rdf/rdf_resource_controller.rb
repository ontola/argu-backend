# frozen_string_literal: false
module ArguRDF
  class RDFResourceController < ApplicationController
    module AuthorizedControllerMethods
      def authenticated_resource
        authenticated_resource! || raise(ActiveRecord::RecordNotFound)
      end

      def authenticated_resource!
        @resource ||=
          case action_name
          when 'create', 'new'
            new_resource_from_params
          else
            resource_by_id
          end
      end

      def parent_resource!
        parent_resource || raise(ActiveRecord::RecordNotFound)
      end

      # modified
      def resource_by_id
        @_resource_by_id ||= controller_class.find(resource_iri)
      end

      def resource_id
        params[:id] || params["#{model_name}_id"]
      end
    end
    include AuthorizedControllerMethods
    include NestedResourceHelper
    include Argu::Authorization
    include Common::Setup
    include Common::Index

    TYPE_MAP = {
      m: 'http://argu.co/ns/core#motions'
    }.freeze

    def index_handler_success(_)
      render json: index_response_association
    end

    def show
      render json: authenticated_resource
    end

    private

    def authenticated_resource
      @resource ||= ArguRDF::Event.find(
        resource_iri,
        **permit_params.to_h.symbolize_keys
      )
    end

    def collection_options
      params
        .permit(:page, filter: controller_class.filter_options.keys)
        .to_h
        .merge(user_context: user_context)
        .to_options
    end

    def controller_class
      "ArguRDF::#{controller_name.classify}".constantize
    end

    # Set in the routes for RDF resources
    def controller_name
      params[:collection_name]
    end

    def parent_from_params(opts = params)
      raise NotImplementedError if parent_resource_class(opts).try(:shortnameable?)
      id = parent_id_from_params(opts)
      parent_resource_class(opts)&.find(
        resource_iri(id),
        id: id
      )
    end

    def parent_resource_klass(opts = params)
      "ArguRDF::#{parent_resource_type(opts).classify}".constantize
    end

    def permit_params
      params.permit(:id)
    end

    def resource_iri(parent_id = nil)
      iri = RDF::URI.parse(request.original_url)
      iri.path = send("#{parent_resource_type}_path", parent_id) if action_name == 'index'
      iri.path = iri.path.split('.')&.first || iri.path
      iri.host = 'beta.argu.dev'
      iri.query = nil
      iri
    end
  end
end
