# frozen_string_literal: true

class QuestionsController < EdgeableController
  include VotesHelper
  include EdgeTree::Move
  skip_before_action :check_if_registered, only: :index

  private

  def include_show
    [
      :default_cover_photo,
      creator: :profile_photo,
      partOf: [widget_sequence: :members],
      operation: :target,
      attachment_collection: inc_nested_collection,
      motion_collection: inc_shallow_collection,
      comment_collection: inc_shallow_collection
    ]
  end

  def show_params
    params.permit(:page)
  end

  def show_respond_success_html(resource)
    @all_motion_edges = policy_scope(
      resource
        .children
        .where(owner_type: 'Motion')
    )
    @motion_edges =
      @all_motion_edges
        .includes(Motion.edge_includes_for_index(true))
        .joins(:default_vote_event)
        .order(sort_from_param)
        .page(show_params[:page])
    preload_user_votes(@motion_edges.map { |edge| edge.default_vote_event.id })
    render locals: {question: resource}
  end

  def sort_from_param
    case sort_param_or_default
    when 'popular'
      "cast(default_vote_events_edges.children_counts -> 'votes_pro' AS int) DESC NULLS LAST, created_at DESC"
    when 'created_at'
      {created_at: :desc}
    when 'updated_at'
      'edges.last_activity_at DESC'
    end
  end
end
