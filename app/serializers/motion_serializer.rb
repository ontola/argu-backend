# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  include Argumentable::Serializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Voteable::Serializer
  attribute :current_vote, predicate: NS::ARGU[:currentVote]
  include_menus

  def current_vote
    object.current_vote&.for
  end
end
