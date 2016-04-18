class GroupMembershipsController < AuthorizedController
  skip_before_action :check_if_member, only: %i(new create)
  include NestedResourceHelper

  def new
    @group = Group.includes(:edge).find(params[:group_id])
    @forum = @group.owner
    authorize @forum, :add_group_member?
    @membership = @group.group_memberships.new

    render 'forums/settings', locals: {
                                tab: 'groups/add',
                                active: tab
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
      format.html do
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

  def create_service
    @create_service ||= CreateGroupMembership.new(
      get_parent_resource,
      attributes: resource_new_params.merge(permit_params),
      options: service_options)
  end

  def parent_resource_param(opts)
    :group_id
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

    forum_path(authenticated_resource!.owner)
  end

  def tab
    @_tab ||= authenticated_resource!.group.shortname == 'managers' ? 'managers' : 'groups'
  end
end
