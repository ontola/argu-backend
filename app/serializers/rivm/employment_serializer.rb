# frozen_string_literal: true

class EmploymentSerializer < EdgeSerializer
  attribute :organization_name, predicate: NS::ARGU[:organizationName], if: method(:never)
  attribute :show_organization_name, predicate: NS::ARGU[:showOrganizationName], if: method(:never)
  attribute :job_title, predicate: NS::SCHEMA[:roleName]
  enum :industry, predicate: NS::SCHEMA[:industry]
end
