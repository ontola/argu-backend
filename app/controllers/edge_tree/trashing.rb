# frozen_string_literal: true
module EdgeTree
  module Trashing
    extend ActiveSupport::Concern

    included do
      define_action_methods(:trash)
      define_action_methods(:untrash)

      private

      # @!visibility public
      def trash_respond_blocks_failure(resource, format)
        format.html { respond_with_redirect_failure(resource, :trash) }
        format.json { response_422_json(resource) }
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
        format.json { response_422_json(resource) }
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
