# frozen_string_literal: true

module Createable
  module Controller
    extend ActiveSupport::Concern

    included do
      define_action(:create)
    end

    def new
      new_handler_success(authenticated_resource)
    end

    private

    # @!visibility public
    def create_respond_blocks_failure(resource, format)
      format.html { create_respond_failure_html(resource) }
      format.js { create_respond_failure_js(resource) }
      format.json { create_respond_failure_json(resource) }
      format.json_api { respond_with_422(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_422(resource, type) }
      end
    end

    # @!visibility public
    def create_respond_blocks_success(resource, format)
      format.html { create_respond_success_html(resource) }
      format.js { create_respond_success_js(resource) }
      format.json { create_respond_success_json(resource) }
      format.json_api { respond_with_201(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_201(resource, type, include: include_create) }
      end
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

    def include_create
      []
    end

    def meta_create
      data = []
      return data if index_collection.blank?
      total_count = index_collection.total_count
      if index_collection.views.present?
        meta_increment_collection_count(data, index_collection.views.first.iri, total_count)
      end
      meta_increment_collection_count(data, index_collection.iri, total_count)
    end

    def meta_increment_collection_count(data, iri, total_count)
      data.push [
        iri,
        NS::ARGU[:members],
        nil,
        NS::LL[:remove]
      ]
      data.push [
        iri,
        NS::ARGU[:totalCount],
        total_count,
        NS::LL[:replace]
      ]
    end

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
