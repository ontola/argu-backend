# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  attribute :pro, predicate: NS.schema.option
  count_attribute :votes_pro
end
