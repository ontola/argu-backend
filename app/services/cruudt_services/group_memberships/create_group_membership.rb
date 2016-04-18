# frozen_string_literal: true
class CreateGroupMembership < CreateService
  include Wisper::Publisher

  def initialize(group, attributes: {}, options: {})
    @group_membership = resource_klass.new
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] = if attributes['shortname'].present?
                            Shortname.find_resource(attributes.delete('shortname')).profile
                          elsif attributes[:member].present?
                            attributes[:member]
                          else
                            options.fetch(:creator)
                          end
    attributes[:profile] = options.fetch(:creator)
    attributes[:group] = group
    super
  end

  def resource
    @group_membership
  end

  private

  def object_attributes=(obj)
  end
end
