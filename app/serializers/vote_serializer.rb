# frozen_string_literal: true
class VoteSerializer < BaseEdgeSerializer
  attributes :option, :explanation, :explained_at, :upvoted_arguments

  def option
    case object.for
    when 'pro'
      'http://schema.org/yes'
    when 'con'
      'http://schema.org/no'
    else
      'http://schema.org/neutral'
    end
  end

  def upvoted_arguments
    Vote
      .joins(edge: :parent)
      .where(voter: object.voter, parents_edges: {parent_id: object.edge.parent_id})
      .map { |vote| vote.parent_model.context_id }
  end
end
