# frozen_string_literal: true
module Service
  module Update
    extend ActiveSupport::Concern

    included do
      define_action_methods(:update)

      private

      # @!visibility public
      def update_respond_blocks_failure(resource, format)
        format.html { render :form, locals: {model_name => resource} }
        format.json { render json: resource.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, resource.errors) }
      end

      # @!visibility public
      def update_respond_blocks_success(resource, format)
        format.html do
          redirect_to redirect_model_success(resource),
                      notice: t('type_save_success', type: type_for(resource))
        end
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
  end
end
