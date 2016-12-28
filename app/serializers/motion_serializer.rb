# frozen_string_literal: true
class MotionSerializer < BaseEdgeSerializer
  include Loggable::Serlializer
  include Argumentable::Serlializer
  include Voteable::Serlializer
  attributes :content
end
