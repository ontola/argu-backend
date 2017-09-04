# frozen_string_literal: true

module Argu
  module StaffConstraint
    module_function

    def matches?(request)
      token = Doorkeeper.authenticate(request)
      return false unless token&.scopes&.include?('user')
      token&.accessible? && User.find(token.resource_owner_id).profile.has_role?(:staff)
    end
  end
end
