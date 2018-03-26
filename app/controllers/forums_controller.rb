# frozen_string_literal: true

class ForumsController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  prepend_before_action :set_layout
  prepend_before_action :write_client_access_token
  skip_before_action :authorize_action, only: %i[discover index]
  skip_before_action :check_if_registered, only: :discover
  skip_after_action :verify_authorized, only: :discover

  BEARER_TOKEN_TEMPLATE = URITemplate.new("#{Rails.configuration.token_url}/{access_token}")

  def index
    edges = current_user.profile.granted_edges(grant_set: %w[moderator administrator])
    @forums = Forum.joins(:edge).where("edges.path ? #{Edge.path_array(edges)}")
    @_pundit_policy_scoped = true
  end

  def discover
    @forums = policy_scope(Forum)
                .public_forums
                .includes(:default_cover_photo, :default_profile_photo, :shortname)
                .page show_params[:page]
    render
  end

  def settings
    respond_with_form
  end

  def show
    return unless policy(resource_by_id).show?
    super
  end

  def statistics
    render :statistics,
           locals: {
             content_counts: content_count(resource_by_id),
             city_counts: city_count(resource_by_id)
           }
  end

  protected

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render 'settings', locals: {
      tab: tab!,
      active: tab!
    }
  end

  private

  def tree_root_id
    return super unless %w[discover index].include?(action_name)
    GrantTree::ANY_ROOT
  end

  def authorize_action
    authorize resource_by_id, :list?
    return super unless action_name == 'show'
  end

  def city_count(forum)
    cities = Hash.new(0)
    User
      .joins(:follows)
      .where(follows: {followable: forum.edge})
      .includes(home_placement: :place)
      .map { |u| u.home_placement&.place&.address.try(:[], 'city') }
      .each { |v| cities.store(v, cities[v] + 1) }
    cities.sort { |x, y| y[1] <=> x[1] }
  end

  def collect_children(resource)
    policy_scope(
      resource
        .edge
        .children
        .where(owner_type: %w[Motion Question])
        .order('edges.pinned_at DESC NULLS LAST, edges.last_activity_at DESC')
    )
      .includes(Question.edge_includes_for_index.deep_merge(Motion.edge_includes_for_index))
      .page(show_params[:page])
      .per(30)
  end

  def content_count(forum)
    forum
      .edge
      .descendants
      .where(owner_type: %w[Argument Vote Question Motion Comment])
      .group(:owner_type)
      .count
      .sort { |x, y| y[1] <=> x[1] }
  end

  def current_forum
    resource_by_id
  end

  def include_show
    [
      :default_cover_photo,
      widget_sequence: :members,
      motion_collection: inc_nested_collection,
      question_collection: inc_nested_collection
    ]
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
    resource = Shortname.find_resource(params[:id]) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Forum)
    send_event category: 'short_url',
               action: 'follow',
               label: params[:id]
    redirect_to resource.iri(only_path: true).to_s
  end

  def redirect_model_success(resource)
    return super unless resource.persisted?
    settings_forum_path(resource, tab: tab)
  end

  def resource_by_id
    return if action_name == 'index' || action_name == 'discover'
    @forum ||= Forum.find_via_shortname_or_id(params[:id])
  end

  def respond_with_form(resource = resource_by_id)
    prepend_view_path 'app/views/forums'
    @grants = Grant
                .custom
                .where(edge_id: [resource_by_id.edge.id, resource_by_id.edge.parent_id])
                .includes(group: {group_memberships: {member: {profileable: :shortname}}})

    render 'settings',
           locals: {
             tab: tab!,
             active: tab!,
             resource: resource
           }
  end

  def respond_with_form_js(_)
    respond_js('forums/settings', tab: tab!, active: tab!)
  end

  def show_params
    params.permit(:page)
  end

  def show_respond_success_html(resource)
    if (/[a-zA-Z]/i =~ params[:id]).nil?
      redirect_to resource.iri(only_path: true).to_s, status: 307
    else
      @children = collect_children(resource)
      render
    end
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Forum).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || params[:forum].try(:[], :tab) || policy(authenticated_resource).default_tab
  end
end
