# frozen_string_literal: true

class MotionsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def index_includes_collection
    current_profile.vote_cache.cache!(parent_resource)
    super
  end

  def index_success_html
    skip_verify_policy_scoped(true)
    redirect_to parent_resource.iri_path
  end

  def show_execute
    @vote = Edge
              .where_owner('Vote', creator: current_profile, primary: true, root_id: root_from_params&.uuid)
              .find_by(parent: authenticated_resource.default_vote_event)
    @vote ||= Vote.new(
      creator: current_profile,
      publisher: current_user,
      parent: authenticated_resource.default_vote_event
    )
    authenticated_resource.current_vote = @vote
  end

  def show_success_html # rubocop:disable Metrics/AbcSize
    @arguments = Argument.ordered(
      policy_scope(
        authenticated_resource
          .pro_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, :votes)
      ),
      policy_scope(
        authenticated_resource
          .con_arguments
          .show_trashed(show_trashed?)
          .includes(:top_comment, :votes)
      ),
      pro: show_params[:page_arg_pro],
      con: show_params[:page_arg_con]
    )
    @comment_edges = authenticated_resource.filtered_threads(false, params[:comments_page])
    respond_with_resource(show_success_options)
  end

  def show_params
    params.permit(:page, :page_arg_pro, :page_arg_con)
  end

  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted? && !afe_request?
    first = current_profile.motions.count == 1 || nil
    authenticated_resource.iri_path(start_motion_tour: first)
  end
end
