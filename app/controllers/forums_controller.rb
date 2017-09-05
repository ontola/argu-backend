# frozen_string_literal: true

class ForumsController < EdgeTreeController
  prepend_before_action :redirect_generic_shortnames, only: :show
  prepend_before_action :set_layout
  prepend_before_action :write_client_access_token
  skip_before_action :authorize_action, only: :discover
  skip_before_action :check_if_registered, only: :discover
  skip_after_action :verify_authorized, only: :discover
  before_action :redirect_bearer_token

  BEARER_TOKEN_TEMPLATE = URITemplate.new("#{Rails.configuration.token_url}/{access_token}")

  def index
    @forums =
      Forum
        .joins(:edge)
        .where(
          'edges.path ? '\
          "#{Edge.path_array(current_user.profile.granted_edges.where('grants.role >= ?', Grant.roles[:manager]))}"
        )
    @_pundit_policy_scoped = true
  end

  def discover
    @forums = policy_scope(Forum)
              .public_forums
              .includes(:default_cover_photo, :default_profile_photo, :shortname)
              .page show_params[:page]
    render
  end

  def show
    return unless policy(resource_by_id).show?

    respond_to do |format|
      format.html do
        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(@forum), status: 307
        else
          @children = collect_children
          render
        end
      end
      format.json
      format.js
      format.json_api do
        render json: authenticated_resource,
               include: [
                 motion_collection: INC_NESTED_COLLECTION,
                 question_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  def settings
    prepend_view_path 'app/views/forums'
    @grants = Grant
                .custom
                .where(edge_id: [resource_by_id.edge.id, resource_by_id.edge.parent_id])
                .includes(group: {group_memberships: {member: {profileable: :shortname}}})

    render locals: {
      tab: tab,
      active: tab,
      resource: resource_by_id
    }
  end

  def statistics
    render :statistics,
           locals: {
             content_counts: content_count(resource_by_id),
             city_counts: city_count(resource_by_id)
           }
  end

  protected

  def correct_stale_record_version
    resource_by_id.reload.attributes = permit_params.reject do |attrb, _value|
      attrb.to_sym == :lock_version
    end
  end

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render 'settings', locals: {
      tab: tab,
      active: tab
    }
  end

  private

  def authenticated_tree
    return if action_name == 'index'
    super
  end

  def authorize_action
    return super unless action_name == 'show'
    authorize resource_by_id, :list?
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

  def collect_children
    policy_scope(
      resource_by_id
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
      .where(owner_type: %w[Argument Vote Project Question Motion Comment])
      .group(:owner_type)
      .count
      .sort { |x, y| y[1] <=> x[1] }
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

  # @todo remove when old links are no longer used
  def redirect_bearer_token
    access_token = AccessToken.find_by(access_token: params[:at])
    return if access_token.blank?
    access_token.increment!(:usages)
    redirect_to BEARER_TOKEN_TEMPLATE.expand(access_token: access_token.access_token)
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = Shortname.find_resource(params[:id]) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Forum)
    send_event category: 'short_url',
               action: 'follow',
               label: params[:id]
    redirect_to url_for(resource)
  end

  def redirect_model_success(resource)
    return super if action_name == 'destroy'
    settings_forum_path(resource, tab: tab)
  end

  def resource_by_id
    return if action_name == 'index' || action_name == 'discover'
    @forum ||= Forum.find_via_shortname_or_id(params[:id])
  end

  def respond_with_form(_)
    render :settings, locals: {tab: tab, active: tab}
  end

  def respond_with_form_js(_)
    respond_js('forums/settings', tab: tab, active: tab)
  end

  def show_params
    params.permit(:page)
  end

  def tab
    t = params[:tab] || params[:forum].try(:[], :tab)
    policy(resource_by_id || Forum).verify_tab(t)
  end
end
