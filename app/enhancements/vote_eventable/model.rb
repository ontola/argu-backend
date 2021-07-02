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
  end
end
