# frozen_string_literal: true

class GrantsController < ServiceController
  private

  def active_response_action_name(_view)
    ACTION_MAP[action_name.to_sym] || action_name.to_sym
  end

  def create_service_parent
    nil
  end

  def create_failure_html
    owner_path = authenticated_resource.edge.owner_type.pluralize.underscore
    render "#{owner_path}/settings",
           locals: {
             tab: 'grants/new',
             active: 'grants',
             page: authenticated_resource.group&.page,
             resource: authenticated_resource.edge
           }
  end

  def new_success_html
    render 'pages/settings',
           locals: {
             tab: 'grants/new',
             active: 'groups',
             resource: authenticated_resource.page,
             grant: authenticated_resource
           }
  end

  def redirect_location
    if authenticated_resource.edge.owner_type == 'Forum'
      settings_iri_path(authenticated_resource.edge)
    else
      settings_iri_path(authenticated_resource.edge, tab: :groups)
    end
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge_id: params[:edge_id] || parent_resource!.uuid,
      group_id: params[:group_id],
      grant_set: GrantSet.participator
    )
  end

  def default_form_view(_action)
    'pages/settings'
  end

  def default_form_view_locals(_action)
    {
      tab: 'grants/new',
      active: 'groups',
      grant: authenticated_resource,
      resource: authenticated_resource.root
    }
  end

  def service_options
    super.except(:publisher, :creator)
  end

  def tree_root_id
    return super unless %w[new create index].include?(action_name)
    @tree_root_id ||= parent_resource.is_a?(Edge) ? parent_resource.root_id : parent_resource&.page&.root_id
  end
end
