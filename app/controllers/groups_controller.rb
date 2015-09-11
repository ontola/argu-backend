class GroupsController < ApplicationController

  def new
    @group = current_forum.groups.new
    authorize @group, :create?

    render 'forums/settings', locals: {
                                tab: 'groups/new',
                                active: 'groups'
                            }
  end

  def create
    @group = current_forum.groups.new
    @group.attributes= permit_params
    authorize @group, :create?

    respond_to do |format|
      if @group.save
        format.html { redirect_to settings_forums_path(tab: :groups) }
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
    @group = Group.find(params[:id])
    authorize @group, :edit?

    render 'forums/settings', locals: {
                                tab: 'groups/edit',
                                active: 'groups'
                            }
  end

  def update
    @group = Group.find(params[:id])
    authorize @group, :update?

    respond_to do |format|
      if @group.update permit_params
        format.html { redirect_to settings_forums_path(tab: :groups) }
      else
        format.html { render 'edit' }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
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

  def destroy!
    @group = Group.find(params[:id])
    authorize @group, :destroy?

    respond_to do |format|
      if @group.destroy
        format.html { redirect_to settings_forums_path(tab: :groups), status: 303 }
      else
        flash[:error] = t('error')
        format.html { redirect_to settings_forums_path(tab: :groups) }
      end
    end
  end


private
  def permit_params
    params.require(:group).permit(*policy(@group || Group).permitted_attributes)
  end
end
