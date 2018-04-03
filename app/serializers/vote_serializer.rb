# frozen_string_literal: true

class VoteSerializer < BaseEdgeSerializer
  attribute :option, predicate: NS::SCHEMA[:option]
  has_one :comment, predicate: NS::ARGU[:explanation]

  has_one :voteable, predicate: NS::SCHEMA[:isPartOf] do
    object.parent_model.voteable
  end

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
