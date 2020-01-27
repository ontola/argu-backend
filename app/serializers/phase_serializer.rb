# frozen_string_literal: true

class PhaseSerializer < ContentEdgeSerializer
  attribute :time, predicate: NS::ARGU[:time]
  attribute :order, predicate: NS::ARGU[:order]
end
