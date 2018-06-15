# frozen_string_literal: true

class ContentEdgeSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :pinned, predicate: NS::ARGU[:pinned]
end
