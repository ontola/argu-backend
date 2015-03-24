class GroupMembershipsController < ApplicationController

  def destroy
    @group_membership = GroupMembership.find params[:id]
    authorize @group_membership, :destroy?

    respond_to do |format|
      if @group_membership.destroy
        format.html { redirect_to settings_forum_path @group_membership.group.forum, tab: :groups }
      else
        format.html { redirect_to settings_forum_path @group_membership.group.forum, tab: :groups }
      end
    end
  end

private
    def permit_params
      params.require(:group).permit(*policy(@group || Group).permitted_attributes)
    end
end