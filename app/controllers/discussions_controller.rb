class DiscussionsController < ApplicationController
  def new
    if params[:forum].present?
      @forum = Forum.find_via_shortname(params[:forum])

    else
      @forum = preferred_forum
    end
    authorize @forum, :list?
  end
end