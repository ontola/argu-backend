# frozen_string_literal: true

module Argu
  module StaffConstraint
    module_function

    def matches?(request) # rubocop:disable Metrics/CyclomaticComplexity
      token = Doorkeeper.authenticate(request)
      return true if token&.scopes&.include?('service') && token.accessible?
      return false unless token&.scopes&.include?('user') && token.accessible?

      GroupMembership
        .joins(:member)
        .joins('INNER JOIN users ON profiles.profileable_type = \'User\' AND profiles.profileable_id = users.uuid')
        .where(group_id: Group::STAFF_ID, users: {id: token.resource_owner_id})
        .any?
    end
  end
end
