# frozen_string_literal: true

module Argu
  module StaffConstraint
    module_function

    def matches?(request)
      token = Doorkeeper.authenticate(request)
      return false unless token&.scopes&.include?('user') && token.accessible?
      GroupMembership
        .joins(:member)
        .where(
          group_id: Group::STAFF_ID,
          profiles: {profileable_type: 'User', profileable_id: token.resource_owner_id}
        )
        .any?
    end
  end
end
