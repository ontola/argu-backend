# frozen_string_literal: true

module Common
  module Show
    extend ActiveSupport::Concern

    included do
      define_handlers(:show)

      def show
        show_handler_success(authenticated_resource)
      end

      private

      # @!visibility public
      def show_respond_blocks_success(resource, format)
        format.js { show_respond_success_js(resource) }
        format.html { show_respond_success_html(resource) }
        format.json { respond_with_200(resource, :json) }
        format.json_api { respond_with_200(resource, :json_api) }
        format.n3 { respond_with_200(resource, :n3) }
        format.nt { respond_with_200(resource, :nt) }
      end
    end
  end
end
