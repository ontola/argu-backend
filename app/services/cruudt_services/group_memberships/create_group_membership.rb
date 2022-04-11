# frozen_string_literal: true

class CreateGroupMembership < CreateService
  def initialize(group, attributes: {}, options: {})
    @resource = group.build_child(GroupMembership, user_context: options[:user_context])
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] ||= options.fetch(:user_context).profile
    attributes[:start_date] ||= Time.current
    super
  end
end
