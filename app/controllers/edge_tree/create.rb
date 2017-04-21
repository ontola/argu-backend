# frozen_string_literal: true
module EdgeTree
  module Create
    extend ActiveSupport::Concern

    included do
      define_action_methods(:create)

      private

      # @!visibility public
      def create_respond_blocks_failure(resource, format)
        format.html { render :form, locals: {model_name => resource} }
        format.json { render json: resource.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, resource.errors) }
      end

      # @!visibility public
      def create_respond_blocks_success(resource, format)
        format.html do
          redirect_to success_redirect_model(resource),
                      notice: t('type_save_success', type: type_for(resource))
        end
        format.json { render json: resource, status: :created, location: resource }
        format.json_api { render json: resource, status: :created, location: resource }
      end
    end
  end
end
