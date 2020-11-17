# frozen_string_literal: true

class VoteEventsController < EdgeableController
  private

  def requested_resource
    return super unless resource_id == VoteEvent::DEFAULT_ID

    parent_resource.default_vote_event
  end
end
