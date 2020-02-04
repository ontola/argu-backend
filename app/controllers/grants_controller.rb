# frozen_string_literal: true

class GrantsController < ServiceController
  private

  def ld_action_name(_view)
    ACTION_MAP[action_name.to_sym] || action_name.to_sym
  end

  def create_service_parent
    nil
  end

  def redirect_location
    settings_iri(authenticated_resource.root, tab: :groups)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge_id: params[:edge_id] || (parent_resource.is_a?(Edge) ? parent_resource!.uuid : nil),
      group_id: params[:group_id],
      grant_set: GrantSet.participator
    )
  end

  def default_form_view(_action)
    'pages/settings'
  end

  def service_options
    super.except(:publisher, :creator)
  end
end
