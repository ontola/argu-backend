# frozen_string_literal: true

module Trashable
  module Controller
    extend ActiveSupport::Concern

    included do
      include Destroyable::Controller

      define_action(:trash)
      define_action(:untrash)
    end

    def bin
      bin_handler_success(authenticated_resource)
    end

    def unbin
      unbin_handler_success(authenticated_resource)
    end

    private

    # @!visibility public
    def bin_respond_blocks_success(resource, format)
      format.html { bin_respond_success_html(resource) }
      format.js { bin_respond_success_js(resource) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_200(resource.action(user_context, :trash), type, include: inc_action_form) }
      end
    end

    # @!visibility public
    def bin_respond_success_html(resource)
      render 'bin', locals: {resource: resource}
    end

    # @!visibility public
    def bin_respond_success_js(resource)
      render 'bin.js',
             layout: false,
             locals: {template: lookup_template('bin'), resource: resource}
    end

    # @!visibility public
    def unbin_respond_blocks_success(resource, format)
      format.html { unbin_respond_success_html(resource) }
      format.js { unbin_respond_success_js(resource) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_200(resource.action(user_context, :untrash), type, include: inc_action_form) }
      end
    end

    # @!visibility public
    def unbin_respond_success_html(resource)
      render 'unbin', locals: {resource: resource}
    end

    # @!visibility public
    def unbin_respond_success_js(resource)
      render 'unbin.js',
             layout: false,
             locals: {template: lookup_template('unbin'), resource: resource}
    end

    # @!visibility public
    def trash_respond_blocks_failure(resource, format)
      format.html { respond_with_redirect_failure(resource, :trash) }
      format.json { respond_with_422(resource, :json) }
      format.json_api { respond_with_422(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_422(resource, type) }
      end
      format.js
    end

    # @!visibility public
    def trash_respond_blocks_success(resource, format)
      format.html { respond_with_redirect_success(resource, :trash) }
      format.json { respond_with_204(resource, :json) }
      format.json_api { respond_with_204(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_204(resource, type) }
      end
      format.js
    end

    # @!visibility public
    def untrash_respond_blocks_failure(resource, format)
      format.html { respond_with_redirect_failure(resource, :untrash) }
      format.json { respond_with_422(resource, :json) }
      format.json_api { respond_with_422(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_422(resource, type) }
      end
      format.js
    end

    # @!visibility public
    def untrash_respond_blocks_success(resource, format)
      format.html { respond_with_redirect_success(resource, :untrash) }
      format.json { respond_with_204(resource, :json) }
      format.json_api { respond_with_204(resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_204(resource, type) }
      end
      format.js
    end
  end
end
