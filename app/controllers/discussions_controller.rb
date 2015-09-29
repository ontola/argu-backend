class DiscussionsController < ApplicationController
  def new
    if params[:forum_id].present?
      @forum = Forum.find_via_shortname(params[:forum_id])
    else
      @forum = preferred_forum
    end
    authorize @forum, :list?
  end
end
