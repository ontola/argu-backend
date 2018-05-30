# frozen_string_literal: true

module Voteable
  extend ActiveSupport::Concern

  included do
    with_collection :vote_events

    after_create :create_default_vote_event
    after_convert :create_default_vote_event

    def create_default_vote_event
      @default_vote_event ||=
        VoteEvent.create!(
          parent: edge,
          creator: creator,
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
