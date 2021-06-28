# frozen_string_literal: true

class ContentEdgeSerializer < EdgeSerializer
  attribute :description, predicate: NS.schema.text
  attribute :follows_count, predicate: NS.argu[:followsCount]
end
