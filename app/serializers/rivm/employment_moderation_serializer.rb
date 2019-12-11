# frozen_string_literal: true

class EmploymentModerationSerializer < EmploymentSerializer
  attribute :organization_name, predicate: NS::ARGU[:organizationName]
  attribute :employee_email, predicate: NS::SCHEMA[:email]
end
