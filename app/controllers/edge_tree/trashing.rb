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
        format.html { redirect_to redirect_model_failure(resource), notice: t('errors.general') }
        format.json { render json: resource.errors, status: :unprocessable_entity }
      end

      # @!visibility public
      def trash_respond_blocks_success(resource, format)
        format.html do
          redirect_to redirect_model_success(resource),
                      notice: t('type_trash_success', type: type_for(resource))
        end
        format.json { head :no_content }
      end

      # @!visibility public
      def untrash_respond_blocks_failure(resource, format)
        format.html { redirect_to redirect_model_failure(resource), notice: t('errors.general') }
        format.json { render json: resource.errors, status: :unprocessable_entity }
      end

      # @!visibility public
      def untrash_respond_blocks_success(resource, format)
        format.html do
          redirect_to redirect_model_success(resource),
                      notice: t('type_untrash_success', type: type_for(resource))
        end
        format.json { head :no_content }
      end
    end
  end
end
