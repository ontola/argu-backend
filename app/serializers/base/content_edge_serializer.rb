# frozen_string_literal: true

class ContentEdgeSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
end
