# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include VotesHelper

  with_collection :votes, predicate: NS::ARGU[:votes]
  attribute :current_vote, predicate: NS::ARGU[:currentVote]
  attribute :pro, predicate: NS::SCHEMA[:option]
  count_attribute :votes_pro

  def current_vote
    current_vote_iri(object)
  end
end
