# frozen_string_literal: true

class CreateGroupMembership < CreateService
  def initialize(group, attributes: {}, options: {})
    @resource = group.build_child(GroupMembership, user_context: options[:user_context])
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] = if attributes['shortname'].present?
                            Shortname.find_resource(attributes.delete('shortname')).profile
                          else
                            attributes[:member].presence || options.fetch(:user_context).profile
                          end
    attributes[:start_date] ||= Time.current
    super
  end

  private

  def object_attributes=(obj); end
end
