# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  has_one :vote, predicate: NS::ARGU[:opinion]
  with_collection :comment_children, predicate: NS::SCHEMA[:comments]

  def description
    object.is_trashed? ? I18n.t('trashed') : object.description || I18n.t('deleted')
  end

  def display_name
    object.title.presence
  end
end
