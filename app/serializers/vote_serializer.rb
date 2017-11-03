# frozen_string_literal: true

class VoteSerializer < BaseEdgeSerializer
  attribute :option, predicate: NS::SCHEMA[:option]
  attribute :explanation, predicate: NS::SCHEMA[:text]
  attribute :explained_at

  has_one :voteable, predicate: NS::SCHEMA[:isPartOf] do
    object.parent_model.voteable
  end

  has_many :upvoted_arguments, predicate: NS::ARGU[:upvotedArguments]

  def option
    case object.for
    when 'pro'
      NS::ARGU[:yes]
    when 'con'
      NS::ARGU[:no]
    else
      NS::ARGU[:other]
    end
  end
end
