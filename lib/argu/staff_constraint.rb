# frozen_string_literal: true

module Argu
  module StaffConstraint
    module_function

    def matches?(request)
      token = Doorkeeper.authenticate(request)

      return false unless token&.accessible?

      token.scopes.include?('service') || token.scopes.include?('staff')
    end
  end
end
