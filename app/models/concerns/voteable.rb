# frozen_string_literal: true

module Voteable
  extend ActiveSupport::Concern

  included do
    has_one :default_vote_event_edge,
            -> { where(owner_type: 'VoteEvent') },
            through: :edge,
            source: :children,
            class_name: 'Edge'
    has_many :votes,
             -> { where(primary: true) },
             as: :voteable,
             dependent: :destroy
    edge_tree_has_many :vote_events
    with_collection :vote_events

    after_create :create_default_vote_event

    def create_default_vote_event
      @default_vote_event ||=
        VoteEvent.create!(
          edge: Edge.new(parent: edge, user: publisher, is_published: true),
          starts_at: Time.current,
          creator_id: creator.id,
          publisher_id: publisher.id,
          forum_id: try(:forum_id),
          root_id: edge.root.uuid
        )
    end

    delegate :default_vote_event, to: :edge
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
