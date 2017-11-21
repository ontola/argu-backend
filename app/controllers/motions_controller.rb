# frozen_string_literal: true

class MotionsController < EdgeableController
  include EdgeTree::Move
  skip_before_action :check_if_registered, only: :index
  skip_before_action :authorize_action, only: :search

  def search
    skip_verify_policy_authorized(true)
    if params[:q].present? && params[:thing].present?
      @motions = policy_scope(parent_resource!.motions).search(params[:q])
      render json: @motions.presence || {data: []}
    else
      skip_verify_policy_scoped(true)
      errors = []
      errors << {title: 'Query parameter `q` not present'} if params[:q].blank?
      errors << {title: 'Type parameter `thing` not present'} if params[:thing].blank?
      render status: 400,
             json: {errors: errors}
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @vote = Edge
              .where_owner('Vote', creator: current_profile)
              .find_by(parent: authenticated_resource.default_vote_event.edge)
              &.owner
    @vote ||= Vote.new(
      voteable_id: authenticated_resource.id,
      voteable_type: authenticated_resource.class.name,
      creator: current_profile,
      edge: Edge.new(parent: authenticated_resource.default_vote_event.edge)
    )
    authenticated_resource.current_vote = @vote

    show_handler_success(authenticated_resource)
  end

  private

  def include_show
    [
      :default_cover_photo,
      con_argument_collection: inc_nested_collection,
      pro_argument_collection: inc_nested_collection,
      attachment_collection: inc_nested_collection,
      vote_event_collection: {member_sequence: {members: {vote_collection: inc_nested_collection}}}
    ]
  end

  def show_respond_success_html(resource)
    @arguments = Argument.ordered(
      policy_scope(
        resource
          .pro_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, edge: :votes)
      ),
      policy_scope(
        resource
          .con_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, edge: :votes)
      ),
      pro: show_params[:page_arg_pro],
      con: show_params[:page_arg_con]
    )
    @comment_edges = resource.filtered_threads(false, params[:comments_page])
    render locals: {motion: resource}
  end

  def show_params
    params.permit(:page, :page_arg_pro, :page_arg_con)
  end

  def redirect_model_success(resource)
    return super unless action_name == 'create' && resource.persisted?
    first = current_profile.motions.count == 1 || nil
    motion_path(resource, start_motion_tour: first)
  end

  def tree_root_id
    return super unless action_name == 'search'
    parent_edge.root_id
  end
end
