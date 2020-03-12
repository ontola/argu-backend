# frozen_string_literal: true

class VoteSerializer < EdgeSerializer
  has_one :comment, predicate: NS::ARGU[:explanation]
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.publisher.show_feed? ? object.creator.profileable : User.anonymous
  end

  has_one :voteable, predicate: NS::SCHEMA[:isPartOf] do
    object.parent.voteable
  end

  attribute :primary, predicate: NS::ARGU[:primaryVote]
  attribute :option, predicate: NS::SCHEMA[:option]
  attribute :display_name, predicate: NS::SCHEMA[:name], unless: :export_scope?

  def option
    NS::ARGU[object.option || :abstain]
  end
end
