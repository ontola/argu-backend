# frozen_string_literal: true

class MoveController < ServiceController
  active_response :new, :create

  private

  def authorize_action
    return authorize parent_resource!, :show? if afe_request? && form_action?

    authorize parent_resource!, :move?
    user_context.with_root(parent_resource!.root) do
      authorize parent_resource!, :update?
    end
  end

  def check_if_registered?
    action_name != 'show' && !(afe_request? && form_action?)
  end

  def create_success
    add_exec_action_header(headers, ontola_redirect_action(authenticated_resource.edge.iri, reload: true))
    super
  end

  def resource_new_params
    {edge: parent_resource!}
  end
end
