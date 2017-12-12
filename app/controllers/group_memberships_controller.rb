# frozen_string_literal: true

class GroupMembershipsController < ServiceController
  skip_before_action :authorize_action, only: :index
  skip_before_action :verify_terms_accepted

  include NestedResourceHelper

  def show
    respond_to do |format|
      format.html do
        flash.keep
        redirect_to redirect_url
      end
      format.json_api { render json: authenticated_resource, include: include_show }
      format.nt { render nt: authenticated_resource, include: include_show }
    end
  end

  def index
    return if params[:q].nil?
    q = params[:q].tr(' ', '|')
    # Matched groups with members
    @results = policy_scope(
      GroupMembership
        .includes(:group, user: [:shortname, :email_addresses, profile: :default_profile_photo])
        .where('groups.page_id = ? AND groups.id > 0', parent_resource!.id)
        .where('shortnames.owner_type = ?', 'User')
        .where('lower(groups.name) SIMILAR TO lower(?) OR ' \
               'lower(shortnames.shortname) SIMILAR TO lower(?) OR ' \
               'lower(users.first_name) SIMILAR TO lower(?) OR ' \
               'lower(users.last_name) SIMILAR TO lower(?)',
               "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")
        .references(:groups, :users)
    )

    render json: @results, include: [:group, user: :profile_photo]
  end

  private

  def create_handler_success(resouce)
    if params[:redirect] == 'false'
      warn '[DEPRECATED] Using redirect = false in GroupMembership#create is deprecated.'
      head 201
    else
      respond_to do |format|
        create_respond_blocks_success(resouce, format)
      end
    end
  end

  def create_respond_blocks_failure(resource, format)
    format.html { redirect_to redirect_url, notice: t('errors.general') }
    format.json do
      if existing_record
        render json: resource.errors, status: 304, location: existing_record
      else
        respond_with_422(resource, :json)
      end
    end
    format.json_api { respond_with_422(resource, :json_api) }
    format.nt { respond_with_422(resource, :nt) }
  end

  alias create_service_parent parent_resource!

  def existing_record
    return @existing_record if @existing_record.present?
    return if authenticated_resource.valid?
    duplicate_values = authenticated_resource
      .errors
      .details
      .select { |_key, errors| errors.select { |error| error[:error] == :taken }.any? }
      .map { |key, errors| [key, errors.find { |error| error[:error] == :taken }[:value]] }
    @existing_record = controller_class
                         .find_by(Hash[duplicate_values].merge(member_id: authenticated_resource.member_id))
  end

  def include_show
    %i[organization]
  end

  def new_respond_success_html(resource)
    redirect_to settings_group_path(resource.group, tab: :invite)
  end

  def parent_resource_key(opts)
    action_name == 'index' ? super : :group_id
  end

  def permit_params
    params.permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def resource_new_params
    {
      group: parent_resource!
    }
  end

  def redirect_param
    params.permit(:r)[:r]
  end

  def redirect_url(_ = nil)
    return redirect_param if redirect_param.present?
    forum_grants = authenticated_resource!.grants.joins(:edge).where(edges: {owner_type: 'Forum'})
    return polymorphic_url(forum_grants.first.edge.owner) if forum_grants.count == 1
    page_url(authenticated_resource!.page)
  end
  alias redirect_model_failure redirect_url
  alias redirect_model_success redirect_url

  def respond_with_201(resource, format)
    return super unless %i[json json_api].include?(format)
    render json: resource, status: :created, location: resource, include: :group
  end
end
