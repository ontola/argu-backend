# frozen_string_literal: true

class DecisionSerializer < EdgeableBaseSerializer
  attribute :content, predicate: NS::SCHEMA[:text]
end
