# frozen_string_literal: true

module Votable
  module Serializer
    extend ActiveSupport::Concern

    included do
      extend URITemplateHelper

      with_collection :votes, predicate: NS.argu[:votes]

      attribute :current_vote, predicate: NS.argu[:currentVote] do |object|
        current_vote_iri(object)
      end
      attribute :create_vote, predicate: NS.argu[:createVote] do |object|
        object.vote_collection.action(:create).iri
      end
      attribute :vote_options_iri, predicate: NS.argu[:voteOptions]
      statements :vote_counts
    end

    class_methods do
      def vote_counts(object, _params)
        object.vote_counts
      end
    end
  end
end
