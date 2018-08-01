# frozen_string_literal: true

class ForumsController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  prepend_before_action :set_layout
  prepend_before_action :write_client_access_token, unless: :afe_request?
  skip_before_action :authorize_action, only: %i[discover index]
  skip_before_action :check_if_registered, only: :discover
  skip_after_action :verify_authorized, only: :discover

  BEARER_TOKEN_TEMPLATE = URITemplate.new("#{Rails.configuration.token_url}/{access_token}")

  active_response :settings

  def index_success_html
    edge_ids =
      current_user
        .profile
        .granted_edges(root_id: tree_root_id, grant_set: %w[moderator administrator])
        .pluck(:uuid)
        .uniq
    @forums = Forum.joins(:parent).where('edges.uuid IN (?) OR parents_edges.uuid IN (?)', edge_ids, edge_ids)
    @_pundit_policy_scoped = true
  end

  def discover
    @forums = Forum
                .public_forums
                .includes(:default_cover_photo, :default_profile_photo)
                .page show_params[:page]
    skip_verify_policy_scoped(true)
    render
  end

  def show
    return unless policy(resource_by_id).show?
    super
  end

  private

  def authorize_action
    authorize authenticated_resource, :list?
    return super unless action_name == 'show'
  end

  def collect_children(resource)
    policy_scope(
      resource
        .children
        .where(owner_type: %w[Motion Question])
        .order('edges.pinned_at DESC NULLS LAST, edges.last_activity_at DESC')
    )
      .includes(Question.edge_includes_for_index.deep_merge(Motion.edge_includes_for_index))
      .page(show_params[:page])
      .per(30)
  end

  def current_forum
    resource_by_id
  end

  def permit_params
    attrs = policy(resource_by_id).permitted_attributes
    pm = params.require(:forum).permit(*attrs).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def photo_params_nesting_path
    []
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = Shortname.find_resource(params[:id], root_from_params&.uuid) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Forum)
    redirect_to resource.iri_path
  end

  def redirect_location
    return super unless authenticated_resource.persisted?
    settings_iri_path(authenticated_resource, tab: tab)
  end

  def settings_success
    respond_with_form(default_form_options(:settings))
  end

  def settings_view
    @grants =
      Grant
        .custom
        .where(edge_id: [resource_by_id.uuid, resource_by_id.parent.uuid])
        .includes(group: {group_memberships: {member: :profileable}})
    'forums/settings'
  end
  alias edit_view settings_view

  def settings_view_locals
    {
      active: tab!,
      resource: authenticated_resource,
      tab: tab!
    }
  end
  alias edit_view_locals settings_view_locals

  def show_includes
    [
      :default_cover_photo,
      widget_sequence: :members
    ]
  end

  def show_params
    params.permit(:page)
  end

  def show_success_html
    if (/[a-zA-Z]/i =~ params[:id]).nil?
      redirect_to resource.iri(only_path: true).to_s, status: 307
    else
      @children = collect_children(authenticated_resource)
      respond_with_resource(show_success_options)
    end
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Forum).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || params[:forum].try(:[], :tab) || policy(authenticated_resource).default_tab
  end
end
