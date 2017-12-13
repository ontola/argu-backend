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

      def include_show
        []
      end

      # @!visibility public
      def show_respond_blocks_success(resource, format)
        format.js { show_respond_success_js(resource) }
        format.html { show_respond_success_html(resource) }
        format.json { show_respond_success_json(resource) }
        format.json_api { show_respond_success_serializer(resource, :json_api) }
        format.n3 { show_respond_success_serializer(resource, :n3) }
        format.nt { show_respond_success_serializer(resource, :nt) }
      end

      def show_respond_success_html(resource)
        render 'show', locals: {resource: resource}
      end

      def show_respond_success_js(_resource)
        raise NotImplementedError
      end

      def show_respond_success_json(_resource)
        respond_with_200(resource, :json)
      end

      def show_respond_success_serializer(resource, format)
        respond_with_200(resource, format, include: include_show)
      end
    end
  end
end
