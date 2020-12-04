# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  has_one :vote, predicate: NS::ARGU[:opinion]
  attribute :pdf_position_x, predicate: NS::ARGU[:pdfPositionX]
  attribute :pdf_position_y, predicate: NS::ARGU[:pdfPositionY]
  attribute :pdf_page, predicate: NS::ARGU[:pdfPage]
  attribute :description, predicate: NS::SCHEMA[:text] do |object|
    object.is_trashed? ? I18n.t('trashed') : object.description
  end
  with_collection :comments, predicate: NS::SCHEMA.comment
end
