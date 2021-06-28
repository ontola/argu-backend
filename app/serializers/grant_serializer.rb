# frozen_string_literal: true

class GrantSerializer < RecordSerializer
  belongs_to :edge, predicate: NS.argu[:edge]
  belongs_to :group, predicate: NS.argu[:group]
  belongs_to :grant_set, predicate: NS.argu[:grantSet]
end
