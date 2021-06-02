# frozen_string_literal: true

class MoveController < ServiceController
  active_response :create

  private

  def authorize_action
    return authorize parent_resource!, :show? if form_action?

    authorize parent_resource!, :move?
    user_context.with_root(parent_resource!.root) do
      authorize parent_resource!, :update?
    end
  end

  def create_success
    add_exec_action_header(headers, ontola_redirect_action(authenticated_resource.edge.iri, reload: true))
    super
  end
end
