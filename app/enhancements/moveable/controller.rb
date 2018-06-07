# frozen_string_literal: true

module Moveable
  module Controller
    extend ActiveSupport::Concern

    included do
      define_handlers(:shift)
    end

    def shift
      shift_handler_success(authenticated_resource)
    end

    def move
      @edge = Edge.find_by(uuid: params[:edge_id])
      user_context.with_root_id(@edge.root_id) do
        authorize @edge, :update?
      end
      moved = false
      authenticated_resource.with_lock do
        moved = authenticated_resource.move_to @edge, *move_options
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
      edit_iri_path(resource)
    end

    def shift_respond_blocks_success(_, format)
      format.html { render :move, locals: {resource: authenticated_resource} }
      format.js { render :move, locals: {resource: authenticated_resource} }
    end
  end
end
