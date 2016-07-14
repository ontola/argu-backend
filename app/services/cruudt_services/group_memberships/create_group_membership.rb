# frozen_string_literal: true
class CreateGroupMembership < EdgeableCreateService
  include Wisper::Publisher

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

  def after_save
    super
    if resource.group.grants.first&.edge&.owner_type == 'Forum'
      forum_edge = resource.group.grants.first.edge
      current_follow_type = resource.publisher.following_type(forum_edge)
      if Follow.follow_types[:news] > Follow.follow_types[current_follow_type]
        resource.publisher.follow(forum_edge, :news)
      end
    end
  end

  def object_attributes=(obj)
  end

  def parent_columns
    %i(group_id)
  end
end
