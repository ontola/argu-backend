# frozen_string_literal: true
class QuestionsController < EdgeTreeController
  include EdgeTree::Move, MenuHelper, VotesHelper
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
            .order("cast(default_vote_event_edges_edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST")
            .page(show_params[:page])
        preload_user_votes(@motion_edges.map { |edge| edge.default_vote_event_edge.id })
        render locals: {question: authenticated_resource}
      end
      format.widget { render authenticated_resource }
      format.json # show.json.jbuilder
      format.json_api do
        render json: authenticated_resource,
               include: [
                 attachment_collection: INC_NESTED_COLLECTION,
                 motion_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  private

  def authenticated_resource
    if (%w(convert convert! shift move) & [params[:action]]).present?
      @resource ||= Question.find(params[:question_id])
    else
      super
    end
  end

  def move_options
    permit_params[:include_motions] == '1'
  end

  def show_params
    params.permit(:page)
  end
end
