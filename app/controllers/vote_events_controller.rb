# frozen_string_literal: true

class VoteEventsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  private

  def include_index
    [members: {vote_collection: {views: [:members, views: :members]}}]
  end

  def include_show
    [vote_collection: inc_nested_collection]
  end

  def show_respond_success_html(resource)
    redirect_to resource.parent_model
  end
end
