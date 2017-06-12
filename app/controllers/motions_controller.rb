# frozen_string_literal: true
class MotionsController < EdgeTreeController
  include EdgeTree::Move
  skip_before_action :check_if_registered, only: :index
  skip_before_action :authorize_action, only: :search

  def search
    skip_verify_policy_authorized(true)
    if params[:q].present? && params[:thing].present?
      @motions = policy_scope(get_parent_resource.motions).search(params[:q])
      render json: @motions.present? ? @motions : {data: []}
    else
      skip_verify_policy_scoped(true)
      errors = []
      errors << {title: 'Query parameter `q` not present'} unless params[:q].present?
      errors << {title: 'Type parameter `thing` not present'} unless params[:thing].present?
      render status: 400,
             json: {errors: errors}
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @vote = Edge
              .where_owner('Vote', creator_id: current_profile)
              .find_by(parent: authenticated_resource.default_vote_event.edge)
              &.owner
    @vote ||= Vote.new(
      voteable_id: authenticated_resource.id,
      voteable_type: authenticated_resource.class.name,
      creator: current_profile,
      edge: Edge.new(parent: authenticated_resource.default_vote_event.edge)
    )
    authenticated_resource.current_vote = @vote

    respond_to do |format|
      format.html do
        @arguments = Argument.ordered(
          policy_scope(authenticated_resource.arguments.show_trashed(show_trashed?).includes(:votes)),
          pro: show_params[:page_arg_pro],
          con: show_params[:page_arg_con]
        )
        @votes = authenticated_resource.votes.where('explanation IS NOT NULL AND explanation != \'\'')
                   .order(created_at: :desc)
                   .page(params[:page_opinions])
        render locals: {motion: authenticated_resource}
      end
      format.widget { render authenticated_resource }
      format.json # show.json.jbuilder
      format.json_api do
        render json: authenticated_resource,
               include: [
                 argument_collection: INC_NESTED_COLLECTION,
                 attachment_collection: INC_NESTED_COLLECTION,
                 vote_event_collection: {members: {vote_collection: INC_NESTED_COLLECTION}}
               ]
      end
    end
  end

  private

  def resource_new_params
    if get_parent_resource.try(:project).present?
      super.merge(project: get_parent_resource.project)
    else
      super
    end
  end

  def show_params
    params.permit(:page, :page_arg_pro, :page_arg_con)
  end

  def redirect_model_success(resource)
    super unless action_name == 'create'
    first = current_profile.motions.count == 1 || nil
    motion_path(resource, start_motion_tour: first)
  end
end
