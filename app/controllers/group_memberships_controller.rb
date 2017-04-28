# frozen_string_literal: true
class GroupMembershipsController < ServiceController
  include NestedResourceHelper

  def show
    respond_to do |format|
      format.html do
        if params[:welcome] == 'true'
          flash[:notice] = t('group_memberships.welcome', group: authenticated_resource.group.name)
        elsif params[:welcome] == 'false'
          flash[:notice] = t('group_memberships.already_member', group: authenticated_resource.group.name)
        end
        redirect_to redirect_url
      end
      format.json_api { render json: authenticated_resource, include: %i(organization) }
    end
  end

  def index
    return if params[:q].nil?
    q = params[:q].tr(' ', '|')
    # Matched groups with members
    @results = policy_scope(
      GroupMembership
        .includes(:group, user: [:shortname, profile: :default_profile_photo])
        .where('groups.page_id = ?', get_parent_resource.id)
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

  def new
    redirect_to settings_group_path(authenticated_resource!.group, tab: :invite)
  end

  def create
    create_service.on(:create_group_membership_successful) do |group_membership|
      if params[:redirect] == 'false'
        warn '[DEPRECATED] Using redirect = false in GroupMembership#create is deprecated.'
        head 201
      else
        respond_to do |format|
          format.html do
            redirect_to redirect_url,
                        notice: t('type_create_success', type: t('group_memberships.type'))
          end
          format.json { render json: group_membership, status: 201, location: group_membership }
        end
      end
    end
    create_service.on(:create_group_membership_failed) do |group_membership|
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('errors.general') }
        format.json do
          if existing_record
            render json: group_membership.errors, status: 304, location: existing_record
          else
            render json: group_membership.errors, status: 422
          end
        end
      end
    end
    create_service.commit
  end

  def destroy
    destroy_service.on(:destroy_group_membership_successful) do
      respond_to do |format|
        format.html do
          redirect_to redirect_url,
                      notice: t('type_destroy_success', type: t('group_memberships.type'))
        end
      end
    end
    destroy_service.on(:destroy_group_membership_failed) do
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('errors.general') }
      end
    end
    destroy_service.commit
  end

  private

  def existing_record
    return @existing_record if @existing_record.present?
    return if authenticated_resource.valid?
    duplicate_values = authenticated_resource
      .errors
      .details
      .select { |_key, errors| errors.select { |error| error[:error] == :taken }.any? }
      .map { |key, errors| [key, errors.find { |error| error[:error] == :taken }[:value]] }
    @existing_record = controller_class.find_by(Hash[duplicate_values])
  end

  def parent_resource_key(opts)
    action_name == 'index' ? super : :group_id
  end

  def permit_params
    params.permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def resource_new_params
    {
      group: get_parent_resource,
      profile: current_profile
    }
  end

  def redirect_param
    params.permit(:r)[:r]
  end

  def redirect_url
    return redirect_param if redirect_param.present?
    forum_grants = authenticated_resource!.grants.joins(:edge).where(edges: {owner_type: 'Forum'})
    return polymorphic_url(forum_grants.first.edge.owner) if forum_grants.count == 1
    page_url(authenticated_resource!.page)
  end

  def granted_resource
    authenticated_resource.group.grants.first&.edge&.owner
  end
end
