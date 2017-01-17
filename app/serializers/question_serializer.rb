# frozen_string_literal: true
class QuestionSerializer < BaseEdgeSerializer
  include Motionable::Serlializer
  attributes :display_name, :content, :potential_action
end
