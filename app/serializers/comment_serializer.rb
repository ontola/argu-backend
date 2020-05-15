# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  has_one :vote, predicate: NS::ARGU[:opinion]
  attribute :is_opinion, predicate: NS::ARGU[:isOpinion], datatype: NS::XSD[:boolean], if: method(:never)
  attribute :description, predicate: NS::SCHEMA[:text] do |object|
    object.is_trashed? ? I18n.t('trashed') : object.description || I18n.t('deleted')
  end
  with_collection :comments, predicate: NS::SCHEMA.comment
end
