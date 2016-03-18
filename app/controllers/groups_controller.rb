class GroupsController < ApplicationController
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
    @forum = Forum.find_via_shortname params[:forum_id]
    @group = @forum.groups.new
    @group.attributes= permit_params
    authorize @group, :create?

    respond_to do |format|
      if @group.save
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      else
        format.html do
          render 'forums/settings', locals: {
                                      tab: 'groups/new',
                                      active: 'groups'
                                  }
        end
      end
    end
  end

  def edit
    authorize @group, :edit?

    render 'forums/settings', locals: {
                                tab: 'groups/edit',
                                active: 'groups'
                            }
  end

  def update
    authorize @group, :update?

    respond_to do |format|
      if @group.update permit_params
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      else
        format.html { render 'edit' }
      end
    end
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
    authorize @group, :destroy?

    respond_to do |format|
      if @group.destroy
        format.html { redirect_to settings_forum_path(@forum, tab: :groups), status: 303 }
      else
        flash[:error] = t('error')
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      end
    end
  end

  private

  def find_forum_and_group
    @group = Group.includes(:forum).find(params[:id])
    @forum = @group.forum
  end

  def permit_params
    params.require(:group).permit(*policy(@group || Group).permitted_attributes)
  end
end
