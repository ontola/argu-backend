class GroupsController < AuthorizedController
  include NestedResourceHelper
  before_action :find_forum_and_group, only: [:edit, :update, :delete, :destroy]

  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    @group = @forum.groups.new
    authorize @group, :create?

    render 'forums/settings', locals: {
                                tab: 'groups/new',
                                active: 'groups'
                            }
  end

  def create
    create_service.on(:create_group_successful) do |group|
      respond_to do |format|
        format.html { redirect_to settings_forum_path(group.forum, tab: :groups) }
      end
    end
    create_service.on(:create_group_failed) do
      respond_to do |format|
        format.html do
          render 'forums/settings',
                 locals: {
                   tab: 'groups/new',
                   active: 'groups'
                 }
        end
      end
    end
    create_service.commit
  end

  def edit
    authorize @group, :edit?

    render 'forums/settings', locals: {
                                tab: 'groups/edit',
                                active: 'groups'
                            }
  end

  def update
    update_service.on(:update_group_successful) do |group|
      respond_to do |format|
        format.html { redirect_to settings_forum_path(group.forum, tab: :groups) }
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
    authorize @group, :destroy?

    locals = {
        group: @group,
        group_memberships_count: @group.group_memberships.count,
        group_responses_count: @group.group_responses.count
    }
    respond_to do |format|
      format.html { render locals: locals }
      format.js { render locals: locals }
    end
  end

  def destroy
    destroy_service.on(:destroy_group_successful) do |group|
      respond_to do |format|
        format.html { redirect_to settings_forum_path(group.forum, tab: :groups), status: 303 }
      end
    end
    destroy_service.on(:destroy_group_failed) do
      respond_to do |format|
        flash[:error] = t('error')
        format.html { redirect_to settings_forum_path(group.forum, tab: :groups) }
      end
    end
    destroy_service.commit
  end

  private

  def find_forum_and_group
    @group = Group.includes(:forum).find(params[:id])
    @forum = @group.forum
  end

  def new_resource_from_params
    Group.new(resource_new_params)
  end

  def permit_params
    params.require(:group).permit(*policy(@group || Group).permitted_attributes)
  end

  def resource_new_params
    {
      forum: get_parent_resource
    }
  end
end
