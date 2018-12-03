# frozen_string_literal: true

class QuestionsController < EdgeableController
  include VotesHelper
  skip_before_action :check_if_registered, only: :index

  private

  def preview_includes
    [
      :default_cover_photo,
      creator: :default_profile_photo,
      top_comment: :creator
    ]
  end

  def show_includes
    super + [
      partOf: [widget_sequence: :members],
      operation: {},
      attachment_collection: inc_nested_collection,
      motion_collection: inc_shallow_collection,
      comment_collection: inc_shallow_collection,
      blog_post_collection: inc_shallow_collection
    ]
  end

  def show_params
    params.permit(:page)
  end

  def show_success_html # rubocop:disable Metrics/AbcSize
    @all_motion_edges = policy_scope(
      authenticated_resource
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
    render locals: {question: authenticated_resource}
  end

  def sort_from_param
    case sort_param_or_default
    when 'popular'
      [
        Edge.order_child_count_sql(:votes_pro, as: 'default_vote_events_edges'),
        {created_at: :desc}
      ]
    when 'created_at'
      {created_at: :desc}
    when 'updated_at'
      Edge.arel_table['last_activity_at'].desc
    end
  end
end
