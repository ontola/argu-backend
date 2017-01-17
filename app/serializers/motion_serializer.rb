# frozen_string_literal: true
class MotionSerializer < BaseCommentSerializer
  include Loggable::Serlializer
  include Argumentable::Serlializer
  include Voteable::Serlializer
  attributes :content, :current_vote

  def current_vote
    object.current_vote&.for
  end
end
