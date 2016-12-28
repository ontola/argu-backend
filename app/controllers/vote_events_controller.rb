# frozen_string_literal: true
class VoteEventsController < AuthorizedController
  include NestedResourceHelper

  def index
    collection = Collection.new(
      association: :vote_events,
      id: url_for([get_parent_resource, :vote_events]),
      member: policy_scope(get_parent_resource.vote_events),
      parent: get_parent_resource,
      title: 'VoteEvents'
    )

    respond_to do |format|
      format.json_api do
        render json: collection, include: {member: collection.member}
      end
    end
  end

  def show
    respond_to do |format|
      format.json_api do
        render json: authenticated_resource
      end
    end
  end
end
