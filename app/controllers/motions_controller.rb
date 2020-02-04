# frozen_string_literal: true

class MotionsController < DiscussionsController
  skip_before_action :check_if_registered, only: :index

  private

  def index_includes_collection
    current_profile.vote_cache.cache!(parent_resource)
    super
  end

  def show_execute
    @vote = Edge
              .where_owner('Vote', creator: current_profile, primary: true, root_id: tree_root_id)
              .find_by(parent: authenticated_resource.default_vote_event)
    @vote ||= Vote.new(
      creator: current_profile,
      publisher: current_user,
      parent: authenticated_resource.default_vote_event
    )
    authenticated_resource.current_vote = @vote
  end

  def show_params
    params.permit(:page, :page_arg_pro, :page_arg_con)
  end

  def redirect_location
    first = current_profile.motions.count == 1 || nil
    authenticated_resource.iri(start_motion_tour: first)
  end
end
