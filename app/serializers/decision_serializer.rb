# frozen_string_literal: true

class DecisionSerializer < EdgeSerializer
  attribute :content, predicate: NS::SCHEMA[:text]
end
