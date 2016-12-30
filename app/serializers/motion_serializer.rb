# frozen_string_literal: true
class MotionSerializer < BaseCommentSerializer
  include Loggable::Serlializer
  include Argumentable::Serlializer
  attributes :content
end
