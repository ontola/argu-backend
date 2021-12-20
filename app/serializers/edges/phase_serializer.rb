# frozen_string_literal: true

class PhaseSerializer < ContentEdgeSerializer
  enum :resource_type,
       predicate: NS.argu[:resourceType],
       options: Hash[Phase.resource_types.map { |key, _| [key, {label: -> { key.classify.constantize.label }}] }]
end
