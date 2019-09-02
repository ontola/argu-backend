# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  has_one :vote, predicate: NS::ARGU[:opinion]
  attribute :is_opinion, predicate: NS::ARGU[:isOpinion], datatype: NS::XSD[:boolean], if: :never
  with_collection :comments, predicate: NS::SCHEMA[:comments]

  def description
    object.is_trashed? ? I18n.t('trashed') : object.description || I18n.t('deleted')
  end

  def display_name
    object.title.presence
  end
end
