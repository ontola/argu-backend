# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  attribute :body, key: :text
end
