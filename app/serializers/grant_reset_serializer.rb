# frozen_string_literal: true

class GrantResetSerializer < RecordSerializer
  belongs_to :edge, predicate: NS.argu[:edge]
  enum :resource_type, predicate: NS.argu[:resourceType]
  enum :action_name, predicate: NS.argu[:actionName]
end
