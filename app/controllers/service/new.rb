# frozen_string_literal: true
module Service
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
        format.js { render js: "window.location = #{request.url.to_json}" }
        format.html { render :form, locals: {model_name => resource} }
        format.json { render json: resource }
      end
    end
  end
end
