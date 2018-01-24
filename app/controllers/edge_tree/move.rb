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
        user_context.with_root_id(@forum.edge.parent_id) do
          authorize @forum, :update?
        end
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
        respond_with_redirect_failure(resource, :move)
      end

      def move_respond_blocks_success(resource, _)
        respond_with_redirect_success(resource, :move)
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
