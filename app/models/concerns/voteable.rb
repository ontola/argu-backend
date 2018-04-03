# frozen_string_literal: true

module Voteable
  extend ActiveSupport::Concern

  included do
    has_one :default_vote_event_edge,
            -> { where(owner_type: 'VoteEvent') },
            through: :edge,
            source: :children,
            class_name: 'Edge'
    has_many :votes, as: :voteable, dependent: :destroy
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
          forum_id: try(:forum_id)
        )
    end

    delegate :default_vote_event, to: :edge
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :vote_event_collection,
              predicate: NS::ARGU[:voteEvents]
      has_one :default_vote_event,
              key: :voteable_vote_event,
              predicate: NS::ARGU[:voteableVoteEvent]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def vote_event_collection
        object.vote_event_collection(user_context: scope)
      end
    end
  end
end
