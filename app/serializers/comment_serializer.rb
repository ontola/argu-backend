# frozen_string_literal: true
class CommentSerializer < BaseEdgeSerializer
  attribute :body, key: :text
end
