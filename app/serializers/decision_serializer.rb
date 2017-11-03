# frozen_string_literal: true

class DecisionSerializer < BaseEdgeSerializer
  attribute :content, predicate: NS::SCHEMA[:text]
end
