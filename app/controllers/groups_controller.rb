class GroupsController < ApplicationController

  def new
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.new

  end

  def create
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.new
    @group.attributes= permit_params

    respond_to do |format|
      if @group.save
        format.html { redirect_to url_for([:settings, @forum, tab: :groups]) }
      else
        format.html { render 'form' }
      end
    end
  end

  def add
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.find params[:id]
    @membership = @group.group_memberships.new
  end

  def add!
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :create_group?
    @group = @forum.groups.find params[:id]
    page = Page.find params[:page_id]

    @membership = @group.group_memberships.new page: page, profile: current_user.profile
    respond_to do |format|
      if @membership.save
        format.html { redirect_to url_for([:settings, @forum, tab: :groups]) }
      else
        format.html { render 'add' }
      end
    end
  end


private
    def permit_params
      params.require(:group).permit(*policy(@group || Group).permitted_attributes)
    end
end