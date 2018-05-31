# frozen_string_literal: true

class VoteSerializer < EdgeSerializer
  has_one :comment, predicate: NS::ARGU[:explanation]
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.are_votes_public ? object.creator.profileable : User.anonymous
  end

  has_one :voteable, predicate: NS::SCHEMA[:isPartOf] do
    object.parent.voteable
  end

  attribute :option, predicate: NS::SCHEMA[:option]
  attribute :display_name, predicate: NS::SCHEMA[:name], except: :export_scope?

  def option
    NS::ARGU[object.option]
  end
end
