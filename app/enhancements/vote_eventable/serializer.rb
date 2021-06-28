# frozen_string_literal: true

module VoteEventable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :vote_events, predicate: NS.argu[:voteEvents]
      has_one :default_vote_event,
              predicate: NS.argu[:voteableVoteEvent]
    end
  end
end
