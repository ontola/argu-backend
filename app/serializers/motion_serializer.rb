# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  include Attachable::Serializer
  include BlogPostable::Serializer
  include Decisionable::Serializer
  include Voteable::Serializer
  include Photoable::Serializer

  attribute :current_vote, predicate: NS::ARGU[:currentVote], unless: :export?
  attribute :pro_count, if: :export?
  attribute :con_count, if: :export?
  attribute :neutral_count, if: :export?

  include_menus

  def current_vote
    object.current_vote&.for
  end

  def con_count
    object.default_vote_event.con_count
  end

  def neutral_count
    object.default_vote_event.neutral_count
  end

  def pro_count
    object.default_vote_event.pro_count
  end
end
