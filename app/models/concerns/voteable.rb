# frozen_string_literal: true
module Voteable
  extend ActiveSupport::Concern
  include PragmaticContext::Contextualizable

  included do
    has_many :votes, as: :voteable, dependent: :destroy
    edge_tree_has_many :vote_events

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

    def vote_event_collection(opts = {})
      Collection.new(
        {
          parent: self,
          association: :vote_events
        }.merge(opts)
      )
    end
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_one :vote_event_collection do
        link(:self) do
          {
            href: "#{object.context_id}/vote_events",
            meta: {
              '@type': 'argu:vote_events'
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
    end
  end
end
