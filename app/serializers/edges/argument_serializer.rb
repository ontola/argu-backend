# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  extend UriTemplateHelper

  with_collection :votes, predicate: NS::ARGU[:votes]
  attribute :current_vote, predicate: NS::ARGU[:currentVote] do |object|
    current_vote_iri(object)
  end
  attribute :pro, predicate: NS::SCHEMA[:option]
  count_attribute :votes_pro
end
