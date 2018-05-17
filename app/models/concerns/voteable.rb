# frozen_string_literal: true

module Voteable
  extend ActiveSupport::Concern

  included do
    has_one_through_edge :default_vote_event
    has_many_through_edge :votes, where: {primary: true}
    has_many_through_edge :vote_events
    with_collection :vote_events

    after_create :create_default_vote_event

    def create_default_vote_event
      @default_vote_event ||=
        VoteEvent.create!(
          parent: edge,
          publisher: publisher,
          is_published: true,
          starts_at: Time.current,
          root_id: edge.root.uuid
        )
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :vote_events, predicate: NS::ARGU[:voteEvents]
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :default_vote_event,
              key: :voteable_vote_event,
              predicate: NS::ARGU[:voteableVoteEvent]
      # rubocop:enable Rails/HasManyOrHasOneDependent
    end
  end
end
