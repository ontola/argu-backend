# frozen_string_literal: true

class QuestionSerializer < BaseEdgeSerializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Motionable::Serializer
  attributes :display_name, :content
end
