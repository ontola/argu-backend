# frozen_string_literal: true
class MotionSerializer < BaseEdgeSerializer
  include Loggable::Serializer
  include Argumentable::Serializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Voteable::Serializer
  attributes :content, :current_vote

  def current_vote
    object.current_vote&.for
  end
end
