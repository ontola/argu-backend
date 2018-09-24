# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  def description
    object.is_trashed? ? I18n.t('trashed') : object.description || I18n.t('deleted')
  end

  def display_name
    object.title.presence
  end
end
