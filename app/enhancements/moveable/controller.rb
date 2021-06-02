# frozen_string_literal: true

module Moveable
  module Controller
    extend ActiveSupport::Concern

    included do
      active_response :shift, :move
    end

    private

    def move_execute
      @edge = Edge.find_by!(uuid: params[:edge_id])
      user_context.with_root(@edge.root) do
        authorize @edge, :update?
      end
      moved = false
      authenticated_resource.with_lock do
        moved = authenticated_resource.move_to @edge, *move_options
      end
      moved
    end

    def move_options
      nil
    end

    def move_failure
      respond_with_redirect(location: edit_iri_path(authenticated_resource))
    end

    def move_success
      respond_with_redirect(location: authenticated_resource.root_relative_iri.to_s)
    end

    def shift_success
      respond_with_form(shift_success_options)
    end

    def shift_success_options
      default_form_options(:move)
    end
  end
end
