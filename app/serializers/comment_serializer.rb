# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  def display_name
    object.title.presence
  end
end
