# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  attribute :pro, predicate: NS::SCHEMA[:option]
  count_attribute :votes_pro
end
