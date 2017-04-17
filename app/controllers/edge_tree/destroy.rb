# frozen_string_literal: true
module EdgeTree
  module Destroy
    extend ActiveSupport::Concern

    included do
      define_action_methods(:destroy)

      private

      # @!visibility public
      def destroy_respond_blocks_failure(resource, format)
        format.html { redirect_to resource, notice: t('errors.general') }
        format.json { render json: resource.errors, status: :unprocessable_entity }
        format.json_api { json_api_error(422, resource.errors) }
        format.js { head :bad_request }
      end

      # @!visibility public
      def destroy_respond_blocks_success(resource, format)
        format.html do
          redirect_to success_redirect_model(resource), notice: t('type_destroy_success', type: type_for(resource))
        end
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
  end
end
