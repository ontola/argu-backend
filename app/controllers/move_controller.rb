# frozen_string_literal: true

class MoveController < ServiceController
  active_response :new, :create

  private

  def authorize_action
    authorize parent_resource!, :move?
    user_context.with_root_id(parent_resource!.root_id) do
      authorize parent_resource!, :update?
    end
  end

  def create_success
    add_exec_action_header(headers, ontola_redirect_action(authenticated_resource.edge.iri_path, reload: true))
    super
  end

  def resource_new_params
    {edge: parent_resource!}
  end
end
