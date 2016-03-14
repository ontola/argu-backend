class GroupResponsesController < AuthorizedController
  def show
    respond_to do |format|
      format.html { redirect_to url_for([authenticated_resource.motion, anchor: authenticated_resource.identifier]) }
    end
  end

  def new
    @group_response = authenticated_resource!
    authorize @group_response, :new?
    @forum = @group_response.forum

    render 'form'
  end

  def create
    motion = Motion.find(params[:motion_id])
    authorize motion, :show?
    group = policy_scope(motion.forum.groups).discussion.find(params[:group_id])
    @cgr = CreateGroupResponse.new current_profile,
                                   permit_params.merge({
                                     forum: authenticated_context,
                                     publisher: current_user,
                                     profile: current_profile,
                                     group: group,
                                     motion: motion,
                                     side: side_param
                                   })
    authorize @cgr.resource, :create?
    @cgr.subscribe(ActivityListener.new)
    @cgr.on(:create_group_response_successful) do |group_response|
      respond_to do |format|
        format.html { redirect_to motion_url(group_response.motion) }
      end
    end
    @cgr.on(:create_group_response_failed) do |group_response|
      respond_to do |format|
        format.html do
          render 'form',
                 locals: {
                   resource: group_response
                 }
        end
      end
    end
    @cgr.commit
  end

  def edit
    @group_response = authenticated_resource!
    authorize @group_response, :edit?
    @forum = @group_response.forum

    render 'form'
  end

  def update
    if authenticated_resource!.update permit_params
      redirect_to authenticated_resource!.motion
    else
      render 'form'
    end
  end

  def destroy
    respond_to do |format|
      if authenticated_resource!.destroy
        format.html { redirect_to motion_path(authenticated_resource!.motion) }
        format.js { render }
      else
        format.js { render json: {notifications: [{type: :error, message: 'Kon reponse niet verwijderen.'}]} }
      end
    end
  end

private
  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      group = Group.find params[:group_id]
      unless @_not_authorized_caught || group.discussion?
        raise Argu::NotAuthorizedError.new(
          record: group,
          query: 'edit?',
          verdict: t('group_responses.errors.must_be_discussion',
                     group_name: group.name))
      end
      motion = Motion.find params[:motion_id]
      @resource = motion.group_responses.new group: group,
                                             forum: group.forum,
                                             publisher: current_user,
                                             side: side_param
    else
      super
    end
  end

  def resource_tenant
    Motion.find(params[:motion_id]).forum
  end

  def permit_params
    params.require(:group_response).permit(*policy(@resource || @group_response || GroupResponse).permitted_attributes)
  end

  def side_param
    params[:side].presence || params[:group_response][:side]
  end
end
