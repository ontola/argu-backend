# frozen_string_literal: true

class PagesController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  skip_before_action :authorize_action, only: %i[settings index]
  skip_before_action :check_if_registered, only: :index

  self.inc_nested_collection = [
    :create_action,
    member_sequence: [members: :profile_photo],
    view_sequence: [
      members: [
        :create_action,
        member_sequence: [members: :profile_photo],
        views: [:create_action, member_sequence: [members: :profile_photo]].freeze
      ].freeze
    ].freeze
  ].freeze

  def show
    @forums = policy_scope(authenticated_resource.forums)
                .includes(:default_cover_photo, :default_profile_photo, :shortname)
                .order('edges.follows_count DESC')
    @profile = authenticated_resource.profile
    show_handler_success(authenticated_resource)
  end

  def new
    authenticated_resource.build_shortname
    authenticated_resource.build_profile

    render locals: {
      page: authenticated_resource,
      errors: {}
    }
  end

  def create
    authenticated_resource.assign_attributes(permit_params)

    if authenticated_resource.save
      respond_to do |format|
        create_respond_blocks_success(authenticated_resource, format)
      end
    else
      respond_to do |format|
        create_respond_blocks_failure(authenticated_resource, format)
      end
    end
  end

  def settings
    authorize authenticated_resource, :update?

    render locals: {
      tab: tab!,
      active: tab!,
      resource: authenticated_resource
    }
  end

  protected

  def authenticated_resource!
    @resource ||=
      case action_name
      when 'create', 'new'
        new_resource_from_params
      when 'trash', 'untrash', 'index'
        nil
      else
        resource_by_id
      end
  end

  def tree_root_id
    return super unless %w[create new index].include?(action_name)
    GrantTree::ANY_ROOT
  end

  private

  def create_respond_failure_html(resource)
    render 'new',
           locals: {
             page: resource,
             errors: resource.errors
           },
           notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
  end

  def create_respond_failure_js(resource)
    respond_js('pages/new', page: resource, errors: resource.errors)
  end

  def destroy_respond_success_html(_resource)
    redirect_to root_path, status: 303, notice: t('type_destroy_success', type: t('pages.type'))
  end

  def destroy_respond_failure_html(resource)
    flash[:error] = t('errors.general')
    redirect_to(delete_page_path(resource))
  end

  def handle_forbidden_html(_exception)
    us_po = policy(current_user) unless current_user.guest?
    return super unless us_po&.max_pages_reached? && request.format.html?
    errors = {}
    errors[:max_allowed_pages] = {
      max: us_po.max_allowed_pages,
      current: current_user.edges.where(owner_type: 'Page').length,
      pages_url: pages_user_url(current_user)
    }
    render 'new', locals: {
      page: new_resource_from_params,
      errors: errors
    }
  end

  def index_collection
    EdgeableCollection.new(
      association_class: Page,
      user_context: user_context,
      association_scope: :open,
      page: params[:page].is_a?(ActionController::Parameters) ? nil : params[:page],
      pagination: true,
      joins: 'LEFT JOIN (SELECT parent_id, SUM(follows_count) AS total_follows FROM edges GROUP BY parent_id) '\
             'AS forum_edges ON edges.id = forum_edges.parent_id',
      order: 'forum_edges.total_follows DESC NULLS LAST'
    )
  end

  def include_show
    [
      :profile_photo,
      vote_match_collection: inc_nested_collection
    ]
  end

  def new_resource_from_params
    Page.new(
      creator: current_profile,
      publisher: current_user,
      is_published: true
    )
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = super
    merge_photo_params(@_permit_params, Page.new)
    @_permit_params[:last_accepted] = Time.current if permit_params[:last_accepted] == '1'
    @_permit_params
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = Shortname.find_resource(params[:id]) || raise(ActiveRecord::RecordNotFound)
    return if resource.owner_type == 'Page'
    redirect_to resource.iri_path
    send_event category: 'short_url',
               action: 'follow',
               label: params[:id]
  end

  def respond_with_form(_resource)
    render :settings, locals: {tab: tab!, active: tab!}
  end

  def respond_with_form_js(_resource)
    respond_js('pages/settings', tab: tab!, active: tab!)
  end

  def redirect_model_success(resource)
    return new_page_path unless resource.persisted?
    settings_iri_path(resource, tab: tab)
  end

  def show_respond_success_html(resource)
    if @forums.count == 1 && !policy(resource).update?
      redirect_to @forums.first.iri_path
    elsif (/[a-zA-Z]/i =~ params[:id]).nil?
      redirect_to resource.iri(only_path: true).to_s, status: 307
    else
      render 'show'
    end
  end

  def tab!
    @verified_tab ||= policy(authenticated_resource || Page).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || policy(authenticated_resource).default_tab
  end
end
