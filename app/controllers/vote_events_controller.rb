# frozen_string_literal: true
class VoteEventsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def index
    skip_verify_policy_scoped(true)
    respond_to do |format|
      format.json_api do
        render json: get_parent_resource.vote_event_collection(collection_options),
               include: [members: {vote_collection: {views: [:members, views: :members]}}]
      end
    end
  end

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
end
