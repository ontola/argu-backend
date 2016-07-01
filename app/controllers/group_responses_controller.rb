# frozen_string_literal: true

class GroupResponsesController < AuthorizedController
  include NestedResourceHelper

  def show
    respond_to do |format|
      format.html do
        redirect_to url_for([authenticated_resource.motion,
                             anchor: authenticated_resource.identifier])
      end
    end
  end

  def new
    @group_response = authenticated_resource!
    authorize @group_response, :new?
    @forum = @group_response.forum

    render 'form'
  end

  def create
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
    @group_response = authenticated_resource!
    authorize @group_response, :edit?
    @forum = @group_response.forum

    render 'form'
  end

  def update
    update_service.on(:update_group_response_successful) do |group_response|
      respond_to do |format|
        format.html { redirect_to group_response.motion }
      end
    end
    update_service.on(:update_group_response_failed) do
      respond_to do |format|
        format.html do
          render 'form'
        end
      end
    end
    update_service.commit
  end

  def destroy
    destroy_service.on(:destroy_group_response_successful) do |group_response|
      respond_to do |format|
          format.html { redirect_to motion_path(group_response.motion) }
          format.js { render }
        end
    end
    destroy_service.on(:destroy_group_response_failed) do |group_response|
      respond_to do |format|
        format.html { redirect_to motion_path(group_response.motion), notice: t('errors.general') }
        format.js do
          render json: {notifications: [{type: :error, message: 'Kon reponse niet verwijderen.'}]}
        end
      end
    end
    destroy_service.commit
  end

  private

  def new_resource_from_params
    group = policy_scope(resource_tenant.groups).discussion.find(params[:group_id])
    unless @_not_authorized_caught || group.discussion?
      raise Argu::NotAuthorizedError.new(
        record: group,
        query: 'edit?',
        verdict: t('group_responses.errors.must_be_discussion',
                   group_name: group.name))
    end
    GroupResponse.new resource_new_params
  end

  def resource_tenant
    Motion.find(params[:motion_id]).forum
  end

  def resource_new_params
    super.merge(
      group: policy_scope(resource_tenant.groups).discussion.find(params[:group_id]),
      creator: current_profile,
      side: side_param,
      motion: Motion.find(params[:motion_id]))
  end

  def permit_params
    params
      .require(:group_response)
      .permit(*policy(@group_response || resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def side_param
    params[:side].presence || params[:group_response][:side]
  end
end
