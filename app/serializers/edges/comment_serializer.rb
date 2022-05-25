# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  attribute :breadcrumb, predicate: NS.ontola[:breadcrumb] do |object|
    RDF::URI("#{object.parent.iri}#comments") if object.parent
  end
  attribute :description, predicate: NS.schema.text do |object|
    object.is_trashed? ? I18n.t('trashed') : object.description
  end
  with_collection :comments, predicate: NS.schema.comment
end
