class GroupsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_member

  def new
    render 'pages/settings', locals: {
                                tab: 'groups/new',
                                active: 'groups',
                                group: authenticated_resource!,
                                resource: authenticated_resource!.page
                            }
  end

  def create
    create_service.on(:create_group_successful) do |group|
      respond_to do |format|
        format.html do
          redirect_to settings_page_path(group.page, tab: :groups)
        end
      end
    end
    create_service.on(:create_group_failed) do |group|
      respond_to do |format|
        format.html do
          render 'forums/settings',
                 locals: {
                   tab: 'groups/new',
                   active: 'groups',
                   group: group
                 }
        end
      end
    end
    create_service.commit
  end

  def edit
    render 'pages/settings',
           locals: {
             tab: 'groups/edit',
             active: 'groups',
             group: authenticated_resource!,
             resource: authenticated_resource!.page
           }
  end

  def update
    update_service.on(:update_group_successful) do |group|
      respond_to do |format|
        format.html do
          redirect_to settings_page_path(group.page, tab: :groups)
        end
      end
    end
    update_service.on(:update_group_failed) do
      respond_to do |format|
        format.html { render 'edit' }
      end
    end
    update_service.commit
  end

  def delete
    locals = {
        group: authenticated_resource!,
        group_memberships_count: authenticated_resource!.group_memberships.count,
        group_responses_count: authenticated_resource!.group_responses.count
    }
    respond_to do |format|
      format.html { render locals: locals }
      format.js { render locals: locals }
    end
  end

  def destroy
    destroy_service.on(:destroy_group_successful) do |group|
      respond_to do |format|
        format.html do
          redirect_to(
            settings_page_path(group.page, tab: :groups),
            status: 303,
            notice: t('type_destroy_success', type: t('groups.type')))
        end
      end
    end
    destroy_service.on(:destroy_group_failed) do
      respond_to do |format|
        flash[:error] = t('error')
        format.html { redirect_to settings_page_path(group.page, tab: :groups) }
      end
    end
    destroy_service.commit
  end

  private

  def new_resource_from_params
    @resource ||= Group.new(resource_new_params)
  end

  def permit_params
    params
      .require(:group)
      .permit(*policy(resource_by_id || new_resource_from_params || Group).permitted_attributes)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: get_parent_resource
    )
  end
end
