# frozen_string_literal: true

class VoteEventsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def resource_by_id
    return super unless resource_id == VoteEvent::DEFAULT_ID

    parent_resource.default_vote_event
  end
end
