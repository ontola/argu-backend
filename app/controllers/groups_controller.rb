class GroupsController < ApplicationController

  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.new
    render 'forums/settings', locals: {
                                tab: 'groups/new',
                                active: 'groups'
                            }
  end

  def create
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.new
    @group.attributes= permit_params

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
    @forum = Forum.find_via_shortname params[:forum_id]
    @group = @forum.groups.find(params[:id])
    authorize @group, :edit?

    render 'forums/settings', locals: {
                                tab: 'groups/edit',
                                active: 'groups'
                            }
  end

  def update
    @forum = Forum.find_via_shortname params[:forum_id]
    @group = @forum.groups.find(params[:id])
    authorize @group, :update?

    respond_to do |format|
      if @group.update permit_params
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      else
        format.html { render 'edit' }
      end
    end
  end

  def add
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :add_group_member?
    @group = @forum.groups.find params[:id]
    @membership = @group.group_memberships.new

    render 'forums/settings', locals: {
                                tab: 'groups/add',
                                active: 'groups'
                            }
  end

  def add!
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :add_group_member?
    @group = @forum.groups.find params[:id]
    profile = Profile.find params[:profile_id]

    @membership = @group.group_memberships.new member: profile, profile: current_user.profile
    respond_to do |format|
      if @membership.save
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      else
        format.html do
          render 'forums/settings', locals: {
                                      tab: 'groups/add',
                                      active: 'groups'
                                  }
        end
      end
    end
  end

  def remove!
    @forum = Forum.find_via_shortname params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.find params[:id]
    profile = Profile.find params[:profile_id]

    @membership = @group.group_memberships.new member: profile, profile: current_user.profile
    respond_to do |format|
      if @membership.save
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      else
        flash[:error] = t('error')
        format.html { redirect_to settings_forum_path(@forum, tab: :groups) }
      end
    end
  end


private
    def permit_params
      params.require(:group).permit(*policy(@group || Group).permitted_attributes)
    end
end
