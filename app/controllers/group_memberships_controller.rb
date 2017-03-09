# frozen_string_literal: true
class GroupMembershipsController < AuthorizedController
  include NestedResourceHelper

  def index
    return if params[:q].nil?
    q = params[:q].tr(' ', '|')
    # Matched groups with members
    @results = policy_scope(
      GroupMembership
        .includes(:group, user: [:shortname, profile: :default_profile_photo])
        .joins('LEFT JOIN grants ON grants.group_id = groups.id AND grants.role = 1')
        .where('grants.id IS NULL')
        .where('groups.page_id = ?', get_parent_resource.id)
        .where('shortnames.owner_type = ?', 'User')
        .where('lower(groups.name) SIMILAR TO lower(?) OR ' \
               'lower(shortnames.shortname) SIMILAR TO lower(?) OR ' \
               'lower(users.first_name) SIMILAR TO lower(?) OR ' \
               'lower(users.last_name) SIMILAR TO lower(?)',
               "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")
        .references(:groups, :users)
    )

    render json: @results, include: %i(group user)
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
        format.json { render json: group_membership.errors, status: 422 }
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
    return root_path if authenticated_resource!.grants.empty?
    polymorphic_url(authenticated_resource!.grants.first.edge.owner)
  end

  def granted_resource
    authenticated_resource.group.grants.first&.edge&.owner
  end
end
