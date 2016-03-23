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
    create_service.subscribe(ActivityListener.new)
    create_service.on(:create_group_response_successful) do |group_response|
      respond_to do |format|
        format.html { redirect_to motion_url(group_response.motion) }
      end
    end
    create_service.on(:create_group_response_failed) do |group_response|
      respond_to do |format|
        format.html do
          render 'form',
                 locals: {
                   resource: group_response
                 }
        end
      end
    end
    create_service.commit
  end

  def edit
    @group_response = GroupResponse.find params[:id]
    authorize @group_response, :edit?
    @forum = @group_response.forum

    render 'form'
  end

  def update
    update_service.subscribe(ActivityListener.new)
    update_service.on(:update_group_response_successful) do |group_response|
      respond_to do |format|
        format.html { redirect_to group_response.motion }
      end
    end
    update_service.on(:update_group_response_failed) do |group_response|
      respond_to do |format|
        format.html do
          render 'form'
        end
      end
    end
    update_service.commit
  end

  def destroy
    destroy_service.subscribe(ActivityListener.new)
    destroy_service.on(:destroy_group_response_successful) do |group_response|
      respond_to do |format|
          format.html { redirect_to motion_path(group_response.motion) }
          format.js { render }
        end
    end
    destroy_service.on(:destroy_group_response_failed) do |group_response|
      respond_to do |format|
        format.html { redirect_to motion_path(group_response.motion), notice: t('errors.general') }
        format.js { render json: {notifications: [{type: :error, message: 'Kon reponse niet verwijderen.'}]} }
      end
    end
    destroy_service.commit
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

  def create_service
    CreateGroupResponse.new current_profile,
                            permit_params.merge({
                                                    forum: authenticated_context,
                                                    publisher: current_user,
                                                    creator: current_profile,
                                                    group: policy_scope(motion.forum.groups).discussion.find(params[:group_id]),
                                                    motion: Motion.find(params[:motion_id]),
                                                    side: side_param
                                                })
  end

  def resource_tenant
    Motion.find(params[:motion_id]).forum
  def destroy_service
    @destroy_service ||= DestroyGroupResponse.new(resource_by_id)
  end

  end

  def permit_params
    params.require(:group_response).permit(*policy(@resource || @group_response || GroupResponse).permitted_attributes)
  end

  def side_param
    params[:side].presence || params[:group_response][:side]
  end

  def update_service
    @update_service ||= UpdateGroupResponse.new(
        resource_by_id,
        permit_params)
  end
end
