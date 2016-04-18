class GroupMembershipsController < AuthorizedController
  skip_before_action :check_if_member
  include NestedResourceHelper

  def index
    if params[:q].present?
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
          .references(:groups, :users))

      render json: @results, include: %i(group user)
    end
  end

  def new
    authorize authenticated_resource.page, :add_group_member?
    render 'groups/settings', locals: {
      tab: 'invite',
      active: 'invite',
      resource: authenticated_resource.group
    }
  end

  def create
    create_service.on(:create_group_membership_successful) do
      if params[:redirect] == 'false'
        head 201
      else
        respond_to do |format|
          format.html do
            redirect_to redirect_url,
                        notice: t('type_create_success', type: t('group_memberships.type'))
          end
        end
      end
    end
    create_service.on(:create_group_membership_failed) do
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('errors.general') }
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

  def authenticated_resource!
    return super if action_name != 'index'
    Edge.new(
      parent: get_parent_resource.members_group.edge,
      owner: GroupMembership.new(group: Group.new(page: get_parent_resource))
    ).owner
  end

  def parent_resource_param(opts)
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
