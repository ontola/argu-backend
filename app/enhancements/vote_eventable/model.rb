# frozen_string_literal: true

module VoteEventable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :vote_events

      after_create :create_default_vote_event
      after_convert :create_default_vote_event

      property :options_vocab_id,
               :linked_edge_id,
               NS.argu[:optionsVocab],
               association: :options_vocab,
               association_class: 'Vocabulary'
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

    def options_vocab
      super || parent.try(:default_options_vocab) || Vocabulary.vote_options
    end

    def previously_changed_relations
      serializer_class = RDF::Serializers.serializer_for(self)

      super.merge(
        serializer_class.relationships_to_serialize.slice(:default_vote_event)
      )
    end
  end
end
