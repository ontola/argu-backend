# frozen_string_literal: true

class QuestionsController < EdgeTreeController
  include VotesHelper
  include EdgeTree::Move
  skip_before_action :check_if_registered, only: :index

  def show
    respond_to do |format|
      format.html do
        @all_motion_edges = policy_scope(
          resource_by_id
            .edge
            .children
            .where(owner_type: 'Motion')
        )
        @motion_edges =
          @all_motion_edges
            .includes(Motion.edge_includes_for_index(true))
            .joins(:default_vote_event_edge)
            .order(sort_from_param)
            .page(show_params[:page])
        preload_user_votes(@motion_edges.map { |edge| edge.default_vote_event_edge.id })
        render locals: {question: authenticated_resource}
      end
      format.widget { render authenticated_resource }
      format.json # show.json.jbuilder
      format.json_api do
        render json: authenticated_resource, include: include_show
      end
      format.n3 do
        render n3: authenticated_resource, include: include_show
      end
    end
  end

  private

  def authenticated_resource
    if (%w[convert convert! shift move] & [params[:action]]).present?
      @resource ||= Question.find(params[:question_id])
    else
      super
    end
  end

  def include_show
    [
      attachment_collection: INC_NESTED_COLLECTION,
      motion_collection: INC_NESTED_COLLECTION
    ]
  end

  def move_options
    permit_params[:include_motions] == '1'
  end

  def show_params
    params.permit(:page)
  end

  def sort_from_param
    case sort_param_or_default
    when 'popular'
      "cast(default_vote_event_edges_edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST"
    when 'created_at'
      {created_at: :desc}
    when 'updated_at'
      'edges.last_activity_at DESC'
    end
  end
end
