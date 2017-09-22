# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  include Argumentable::Serializer
  include Attachable::Serializer
  include BlogPostable::Serializer
  include Commentable::Serializer
  include Decisionable::Serializer
  include Voteable::Serializer
  include Photoable::Serializer
  attribute :current_vote, predicate: NS::ARGU[:currentVote]
  include_menus

  def current_vote
    object.current_vote&.for
  end
end
