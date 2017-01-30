# frozen_string_literal: true
module Voteable
  extend ActiveSupport::Concern
  include PragmaticContext::Contextualizable

  included do
    has_one :default_vote_event_edge,
            -> { where(owner_type: 'VoteEvent') },
            through: :edge,
            source: :children,
            class_name: 'Edge'
    has_many :votes, as: :voteable, dependent: :destroy
    edge_tree_has_many :vote_events
    has_collection :vote_events

    after_create :create_default_vote_event

    def create_default_vote_event
      VoteEvent.create!(
        edge: Edge.new(parent: edge, user: publisher),
        starts_at: DateTime.current,
        creator_id: creator.id,
        publisher_id: publisher.id,
        forum_id: try(:forum_id)
      )
    end

    def default_vote_event
      @default_vote_event ||= VoteEvent.joins(:edge).where(edges: {parent_id: edge.id}).find_by(group_id: -1)
    end
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :vote_event_collection do
        link(:self) do
          {
            href: "#{object.context_id}/vote_events",
            meta: {
              '@type': 'argu:voteEvents'
            }
          }
        end
        link(:related) do
          {
            href: "#{object.context_id}/vote_events",
            meta: {
              '@type': 'argu:VoteEventCollection'
            }
          }
        end
      end

      def vote_event_collection
        object.vote_event_collection(user_context: scope)
      end
    end
  end
end
