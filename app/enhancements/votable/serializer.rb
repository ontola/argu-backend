# frozen_string_literal: true

module Votable
  module Serializer
    extend ActiveSupport::Concern

    included do
      extend UriTemplateHelper

      with_collection :votes, predicate: NS::ARGU[:votes]

      attribute :current_vote, predicate: NS::ARGU[:currentVote] do |object|
        current_vote_iri(object)
      end
    end
  end
end
