# frozen_string_literal: true

class MeasureSerializer < ContentEdgeSerializer
  attribute :comments_allowed, predicate: NS::RIVM[:commentsAllowed]

  enum :comments_allowed
end
