# frozen_string_literal: true

class ForumsController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  prepend_before_action :set_layout
  skip_before_action :authorize_action, only: %i[discover index]
  skip_before_action :check_if_registered, only: %i[discover index]
  skip_after_action :verify_authorized, only: :discover
  helper_method :forum_grants

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

  def form_view_locals
    {
      resource: resource,
      controller_name.singularize.to_sym => resource
    }
  end

  def forum_grants
    @forum_grants ||=
      Grant
        .custom
        .where(edge_id: [resource_by_id.uuid, resource_by_id.parent.uuid])
        .includes(group: {group_memberships: {member: :profileable}})
  end

  def permit_params
    attrs = policy(resource_by_id || new_resource_from_params).permitted_attributes
    pm = params.require(:forum).permit(*attrs).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def photo_params_nesting_path
    []
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = Shortname.find_resource(params[:id], tree_root_id) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Forum)
    redirect_to resource.iri
  end

  def show_params
    params.permit(:page)
  end

  def show_success_html
    if (/[a-zA-Z]/i =~ params[:id]).nil?
      redirect_to resource.iri, status: 307
    else
      @children = collect_children(authenticated_resource)
      respond_with_resource(show_success_options)
    end
  end

  def signals_failure
    super + [:"#{action_name}_ori_forum_failed"]
  end

  def signals_success
    super + [:"#{action_name}_ori_forum_successful"]
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Forum).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || params[:forum].try(:[], :tab) || policy(authenticated_resource).default_tab
  end
end
