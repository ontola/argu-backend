# frozen_string_literal: true

class MeasureSerializer < ContentEdgeSerializer
  enum :comments_allowed, predicate: NS::RIVM[:commentsAllowed]
end
