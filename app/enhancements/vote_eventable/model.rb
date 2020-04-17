# frozen_string_literal: true

module VoteEventable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :vote_events

      after_create :create_default_vote_event
      after_convert :create_default_vote_event
    end

    def create_default_vote_event
      # rubocop:disable Naming/MemoizedInstanceVariableName
      @default_vote_event ||=
        VoteEvent.create!(
          parent: self,
          creator: creator,
          publisher: publisher,
          is_published: true,
          starts_at: Time.current,
          root_id: root.uuid
        )
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end

    def vote_for(user)
      user.profile.vote_cache.by_parent(default_vote_event)
    end

    module ClassMethods
      def includes_for_serializer
        super.merge(default_vote_event: {creator: :profileable})
      end

      def show_includes
        super + [
          default_vote_event: [
            :current_vote,
            vote_collection: {
              filter_fields: :options,
              filters: [],
              sortings: []
            }.freeze
          ].freeze
        ]
      end
    end
  end
end
