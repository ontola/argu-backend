# frozen_string_literal: true

module EdgeTree
  module Trashing
    extend ActiveSupport::Concern

    included do
      define_action_methods(:trash)
      define_action_methods(:untrash)
      define_handlers(:bin)
      define_handlers(:unbin)

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
      end

      # @!visibility public
      def bin_respond_success_html(resource)
        render 'bin', locals: {resource: resource}
      end

      # @!visibility public
      def bin_respond_success_js(resource)
        render 'bin.js', layout: false, locals: {template: lookup_template('bin'), resource: resource}
      end

      # @!visibility public
      def unbin_respond_blocks_success(resource, format)
        format.html { unbin_respond_success_html(resource) }
        format.js { unbin_respond_success_js(resource) }
      end

      # @!visibility public
      def unbin_respond_success_html(resource)
        render 'unbin', locals: {resource: resource}
      end

      # @!visibility public
      def unbin_respond_success_js(resource)
        render 'unbin.js', layout: false, locals: {template: lookup_template('unbin'), resource: resource}
      end

      # @!visibility public
      def trash_respond_blocks_failure(resource, format)
        format.html { respond_with_redirect_failure(resource, :trash) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
        format.js
      end

      # @!visibility public
      def trash_respond_blocks_success(resource, format)
        format.html { respond_with_redirect_success(resource, :trash) }
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
        format.js
      end

      # @!visibility public
      def untrash_respond_blocks_failure(resource, format)
        format.html { respond_with_redirect_failure(resource, :untrash) }
        format.json { respond_with_422(resource, :json) }
        format.json_api { respond_with_422(resource, :json_api) }
        format.js
      end

      # @!visibility public
      def untrash_respond_blocks_success(resource, format)
        format.html { respond_with_redirect_success(resource, :untrash) }
        format.json { respond_with_204(resource, :json) }
        format.json_api { respond_with_204(resource, :json_api) }
        format.js
      end
    end
  end
end
