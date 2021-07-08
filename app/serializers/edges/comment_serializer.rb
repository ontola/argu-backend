# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  attribute :description, predicate: NS.schema.text do |object|
    object.is_trashed? ? I18n.t('trashed') : object.description
  end
  with_collection :comments, predicate: NS.schema.comment
end
