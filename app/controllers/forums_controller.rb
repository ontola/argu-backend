# frozen_string_literal: true
class ForumsController < EdgeTreeController
  prepend_before_action :redirect_generic_shortnames, only: :show
  prepend_before_action :set_layout
  prepend_before_action :write_client_access_token
  skip_before_action :authorize_action, only: %i(discover)
  skip_before_action :check_if_registered, only: %i(discover)
  skip_after_action :verify_authorized, only: %i(discover)
  before_action :redirect_bearer_token

  BEARER_TOKEN_TEMPLATE = URITemplate.new("#{Rails.configuration.token_url}/{access_token}")

  def index
    @forums = Forum
                .joins(:edge)
                .where('forums.page_id IN(?) OR edges.path ~ ?',
                       current_user.profile.pages.pluck(:id),
                       mangager_edges_sql)
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

    @items = collect_items

    respond_to do |format|
      format.html do
        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(@forum), status: 307
        else
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

  def forum_for(url_options)
    Forum.find_via_shortname_nil(url_options[:id])
  end

  protected

  def correct_stale_record_version
    resource_by_id.reload.attributes = permit_params.reject do |attrb, _value|
      attrb.to_sym == :lock_version
    end
  end

  def get_parent_edge
    # TODO: handle actions where `authenticated_resource!` is not present
    @parent_edge ||= authenticated_resource!.page.edge
  end

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render 'settings', locals: {
      tab: tab,
      active: tab
    }
  end

  private

  def authorize_action
    if action_name == 'show'
      authorize resource_by_id, :list?
    else
      authorize authenticated_resource! || Forum, "#{params[:action].chomp('!')}?"
    end
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

  def collect_items
    projects = policy_scope(resource_by_id
                              .projects
                              .includes(:edge, :default_cover_photo))
    questions = policy_scope(resource_by_id
                               .questions
                               .where(project_id: nil)
                               .includes(:edge, :default_cover_photo))
    motions = policy_scope(resource_by_id
                             .motions
                             .where(project_id: nil, question_id: nil)
                             .includes(:edge, :default_cover_photo, :votes))

    Kaminari
      .paginate_array((projects + questions + motions)
                        .sort_by { |i| [i.pinned ? 1 : 0, i.last_activity_at] }
                        .reverse)
      .page(show_params[:page])
      .per(30)
  end

  def content_count(forum)
    forum
      .edge
      .descendants
      .where(owner_type: %w(Argument Vote Project Question Motion Comment))
      .group(:owner_type)
      .count
      .sort { |x, y| y[1] <=> x[1] }
  end

  def mangager_edges_sql
    ids = current_user.profile.granted_edge_ids(nil, :manager) +
      current_user.profile.granted_edge_ids(nil, :super_admin)
    "*.#{ids.compact.uniq.join('|').presence || 'NULL'}.*"
  end

  def permit_params
    pm = params.require(:forum).permit(*policy(resource_by_id).permitted_attributes).to_h
    merge_photo_params(pm, @resource.class)
    pm
  end

  def photo_params_nesting_path
    []
  end

  # @todo remove when old links are no longer used
  def redirect_bearer_token
    access_token = AccessToken.find_by(access_token: params[:at])
    return unless access_token.present?
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

  def resource_by_id
    return if action_name == 'index' || action_name == 'discover'
    @forum ||= Forum.find_via_shortname!(params[:id])
  end

  def show_params
    params.permit(:page)
  end

  def tab
    policy(resource_by_id || Forum).verify_tab(params[:tab] || params[:forum].try(:[], :tab))
  end

  def update_handler_failure(_)
    render 'settings',
           locals: {
             tab: tab,
             active: tab
           }
  end

  def update_handler_success(resource)
    redirect_to settings_forum_path(resource, tab: tab),
                notice: t('type_save_success', type: t('forums.type'))
  end
end
