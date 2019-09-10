# frozen_string_literal: true

class EmploymentSerializer < EdgeSerializer
  attribute :organization_name, predicate: NS::ARGU[:organizationName], if: :never
  attribute :job_title, predicate: NS::SCHEMA[:roleName]
  attribute :industry, predicate: NS::SCHEMA[:industry]

  enum :industry
end
