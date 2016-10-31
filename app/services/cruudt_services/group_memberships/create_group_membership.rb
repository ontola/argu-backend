# frozen_string_literal: true
class CreateGroupMembership < EdgeableCreateService
  def initialize(group, attributes: {}, options: {})
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] = if attributes['shortname'].present?
                            Shortname.find_resource(attributes.delete('shortname')).profile
                          elsif attributes[:member].present?
                            attributes[:member]
                          else
                            options.fetch(:creator)
                          end
    attributes[:profile] = options.fetch(:creator)
    super
  end

  private

  def object_attributes=(obj)
  end

  def parent_columns
    %i(group_id)
  end
end
