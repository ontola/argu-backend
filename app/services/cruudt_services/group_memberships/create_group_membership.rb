# frozen_string_literal: true

class CreateGroupMembership < CreateService
  def initialize(group, attributes: {}, options: {})
    @resource = GroupMembership.new(group: group)
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] = if attributes['shortname'].present?
                            Shortname.find_resource(attributes.delete('shortname')).profile
                          else
                            attributes[:member].presence || options.fetch(:creator)
                          end
    attributes[:start_date] ||= Time.current
    super
  end

  private

  def after_save
    if resource.member.profileable.is_a?(User)
      forum_edge_ids = resource.grants.joins(:edge).where(edges: {owner_type: 'Forum'}).pluck('edges.uuid').uniq
      if forum_edge_ids.empty? && resource.grants.joins(:edge).where(edge: resource.page).present?
        forum_edge_ids = resource.page.children.where(owner_type: 'Forum').pluck(:uuid)
      end
      forum_edge_ids.each do |forum_edge_id|
        Favorite.create(user: resource.member.profileable, edge_id: forum_edge_id)
      end
    end
    super
  end

  def object_attributes=(obj); end
end
