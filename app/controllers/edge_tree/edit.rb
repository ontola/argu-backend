# frozen_string_literal: true
module EdgeTree
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
        format.html { render :form, locals: {model_name => resource} }
        format.json { render json: resource }
      end
    end
  end
end
