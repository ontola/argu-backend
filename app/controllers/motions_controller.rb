# frozen_string_literal: true

class MotionsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  # GET /motions/1
  # GET /motions/1.json
  def show
    @vote = Edge
              .where_owner('Vote', creator: current_profile, primary: true, root_id: root_from_params&.uuid)
              .find_by(parent: authenticated_resource.default_vote_event)
    @vote ||= Vote.new(
      creator: current_profile,
      publisher: current_user,
      parent: authenticated_resource.default_vote_event
    )
    authenticated_resource.current_vote = @vote

    show_handler_success(authenticated_resource)
  end

  private

  def include_index_collection
    members = [
      members: [
        comment_collection: inc_nested_collection,
        con_argument_collection: inc_nested_collection,
        default_vote_event: vote_event_without_votes,
        pro_argument_collection: inc_nested_collection
      ]
    ].freeze

    [
      default_view: members,
      operation: inc_action_form
    ].freeze
  end

  def include_show
    [
      :vote_event_collection,
      :default_cover_photo,
      creator: :profile_photo,
      operation: inc_action_form,
      partOf: [widget_sequence: :members],
      blog_posts_collection: inc_nested_collection,
      comment_collection: inc_nested_collection,
      con_argument_collection: inc_nested_collection,
      pro_argument_collection: inc_nested_collection,
      attachment_collection: inc_nested_collection,
      default_vote_event: vote_event_without_votes
    ]
  end

  def show_respond_success_html(resource)
    @arguments = Argument.ordered(
      policy_scope(
        resource
          .pro_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, :votes)
      ),
      policy_scope(
        resource
          .con_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, :votes)
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
    resource.iri_path(start_motion_tour: first)
  end

  def vote_event_without_votes
    [
      :current_vote,
      vote_collection: {
        operation: inc_action_form,
        default_filtered_collections: inc_shallow_collection
      }.freeze
    ].freeze
  end
end
