# frozen_string_literal: true
module EdgeTree
  module Move
    extend ActiveSupport::Concern

    included do
      define_handlers(:shift)

      def shift
        shift_handler_success(authenticated_resource)
      end

      def move
        @forum = Forum.find permit_params[:forum_id]
        authorize @forum, :update?
        moved = false
        authenticated_resource.with_lock do
          moved = authenticated_resource.move_to @forum, *move_options
        end
        if moved
          move_respond_blocks_success(authenticated_resource, nil)
        else
          move_respond_blocks_failure(authenticated_resource, nil)
        end
      end

      private

      def move_options
        nil
      end

      def move_respond_blocks_failure(resource, _)
        redirect_to redirect_model_failure(resource)
      end

      def move_respond_blocks_success(resource, _)
        redirect_to resource
      end

      def redirect_model_failure(resource)
        url_for(
          controller: controller_name,
          action: :edit,
          id: resource.id
        )
      end

      def shift_respond_blocks_success(_, format)
        format.html { render :move, locals: {resource: authenticated_resource} }
        format.js { render :move, locals: {resource: authenticated_resource} }
      end
    end
  end
end
