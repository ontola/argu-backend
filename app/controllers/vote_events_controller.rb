# frozen_string_literal: true

class VoteEventsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def include_index
    [member_sequence: {members: include_show}]
  end

  def include_show
    [:current_vote, vote_collection: inc_nested_collection]
  end

  def resource_by_id
    return super unless resource_id == VoteEvent::DEFAULT_ID
    parent_resource.default_vote_event
  end

  def show_respond_success_html(resource)
    redirect_to resource.parent
  end
end
