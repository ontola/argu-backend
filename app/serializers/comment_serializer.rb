# frozen_string_literal: true

class CommentSerializer < ContentEdgeSerializer
  attribute :body, predicate: 'http//schema.org/text', key: :text
  include_menus
end
