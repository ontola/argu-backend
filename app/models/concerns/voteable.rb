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
    with_collection :vote_events

    after_create :create_default_vote_event

    def mixed_comments(order = 'comments.created_at DESC')
      @mixed_comments ||=
        Edge
          .joins("LEFT JOIN votes ON edges.owner_id = votes.id AND edges.owner_type = 'Vote'")
          .joins("LEFT JOIN comments ON edges.owner_id = comments.id AND edges.owner_type = 'Comment'")
          .where(parent_id: [edge.id, default_vote_event.edge.id])
          .where(owner_type: %w[Comment Vote])
          .where("votes.id IS NULL OR votes.explanation IS NOT NULL AND votes.explanation != ''")
          .where('comments.id IS NULL OR comments.parent_id IS NULL')
          .includes(:parent, owner: {creator: Profile.includes_for_profileable})
          .order(order)
    end

    def create_default_vote_event
      VoteEvent.create!(
        edge: Edge.new(parent: edge, user: publisher, is_published: true),
        starts_at: DateTime.current,
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

      has_one :default_vote_event, key: :voteable_vote_event do
        obj = object.default_vote_event
        if obj
          link(:self) do
            {
              href: obj.context_id,
              meta: {
                '@type': 'argu:voteableVoteEvent'
              }
            }
          end
          link(:related) do
            {
              href: obj.context_id,
              meta: {
                '@type': obj.context_type
              }
            }
          end
        end
        obj
      end

      def vote_event_collection
        object.vote_event_collection(user_context: scope)
      end
    end
  end
end
