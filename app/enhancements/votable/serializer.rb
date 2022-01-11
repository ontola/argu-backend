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
    end
  end
end
