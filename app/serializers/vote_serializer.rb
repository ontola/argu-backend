# frozen_string_literal: true

class VoteSerializer < BaseEdgeSerializer
  has_one :comment, predicate: NS::ARGU[:explanation]
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.are_votes_public ? object.creator.profileable : User.anonymous
  end

  has_one :voteable, predicate: NS::SCHEMA[:isPartOf] do
    object.parent_model.voteable
  end

  attribute :option, predicate: NS::SCHEMA[:option]
  attribute :display_name, predicate: NS::SCHEMA[:name], expect: :export?

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
