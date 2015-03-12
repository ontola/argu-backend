class GroupResponsesController < ApplicationController

  def new
    group = Group.find params[:group_id]
    motion = Motion.find params[:motion_id]
    @group_response = motion.group_responses.new group: group, forum: group.forum, created_by: current_profile, side: params[:side]
    authorize @group_response, :new?

    render 'form'
  end

  def create
    group = Group.find params[:group_id]
    motion = Motion.find params[:motion_id]
    @group_response = motion.group_responses.new group: group, forum: group.forum, profile: current_profile, created_by: current_user.profile, side: params[:side]
    @group_response.attributes= permit_params
    authorize @group_response, :create?

    respond_to do |format|
      if @group_response.save
        format.html { redirect_to @group_response.motion }
      else
        format.html { render 'form' }
      end
    end
  end

  def edit
    @group_response = GroupResponse.find params[:id]
    authorize @group_response, :edit?

    render 'form'
  end

  def update
    @group_response = GroupResponse.find params[:id]
    authorize @group_response, :edit?

    if @group_response.update permit_params
      redirect_to @group_response.motion
    else
      render 'form'
    end
  end

  def destroy
    @group_response = GroupResponse.find params[:id]
    authorize @group_response, :destroy?

    respond_to do |format|
      if @group_response.destroy
        format.js { render }
      else
        format.js { render json: {notifications: [{type: :error, message: 'Kon reponse niet verwijderen.'}]} }
      end
    end
  end

private
    def permit_params
      params.require(:group_response).permit(*policy(@group_response || GroupResponse).permitted_attributes)
    end
end