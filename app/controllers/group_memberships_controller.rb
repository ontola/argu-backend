class GroupMembershipsController < ApplicationController

  def new
    authorize current_forum, :add_group_member?
    @group = Group.find(params[:group_id])
    @membership = @group.group_memberships.new

    render 'forums/settings', locals: {
                                tab: 'groups/add',
                                active: 'groups'
                            }
  end

  def create
    authorize current_forum, :add_group_member?
    @group = Group.find(params[:group_id])
    profile = Shortname.find_resource(params[:profile_id]).profile

    @membership = @group.group_memberships.new member: profile, profile: current_user.profile
    respond_to do |format|
      if @membership.save
        format.html { redirect_to settings_forums_path(tab: :groups) }
      else
        format.html do
          render 'forums/settings',
                 locals: {
                     tab: 'groups/add',
                     active: 'groups'
                 }
        end
      end
    end
  end

  def destroy
    @group_membership = GroupMembership.find params[:id]
    authorize @group_membership, :destroy?

    respond_to do |format|
      if @group_membership.destroy
        format.html { redirect_to settings_forums_path tab: :groups }
      else
        format.html { redirect_to settings_forums_path tab: :groups }
      end
    end
  end

private
    def permit_params
      params.require(:group).permit(*policy(@group || Group).permitted_attributes)
    end
end
