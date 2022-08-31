# frozen_string_literal: true

module Moveable
  module Controller
    extend ActiveSupport::Concern

    included do
      has_resource_action(
        :move,
        form: MoveForm,
        policy: :move?
      )
    end

    private

    def move_execute
      current_resource!.move_to(permit_params[:new_parent_id])
    end

    def move_success
      respond_with_redirect(
        location: current_resource.iri,
        reload: true
      )
    end

    def move_failure
      update_failure
    end
  end
end
