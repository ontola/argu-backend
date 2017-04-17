# frozen_string_literal: true
class VoteEventsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  def show
    respond_to do |format|
      format.html do
        render 'show', locals: {resource: authenticated_resource}
      end
      format.json_api do
        render json: authenticated_resource, include: [vote_collection: INC_NESTED_COLLECTION]
      end
    end
  end

  private

  def include_index
    [members: {vote_collection: {views: [:members, views: :members]}}]
  end
end
