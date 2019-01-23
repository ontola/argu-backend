# frozen_string_literal: true

module Argu
  module NoTenantConstraint
    module_function

    def matches?(_request)
      ActsAsTenant.current_tenant.nil?
    end
  end
end
