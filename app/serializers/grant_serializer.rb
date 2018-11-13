# frozen_string_literal: true

class GrantSerializer < RecordSerializer
  belongs_to :edge, predicate: NS::ARGU[:edge]
  belongs_to :group, predicate: NS::ARGU[:group]
  belongs_to :grant_set, predicate: NS::ARGU[:grantSet]
end
