# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  include_menus

  def display_name
    object.title.presence
  end
end
