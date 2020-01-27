# frozen_string_literal: true

class ProjectSerializer < ContentEdgeSerializer
  has_one :current_phase, predicate: NS::ARGU[:currentPhase]
end
