# frozen_string_literal: true

class CreateGroupMembership < CreateService
  def initialize(group, attributes: {}, options: {})
    @resource = GroupMembership.new(group: group)
    attributes = HashWithIndifferentAccess.new(attributes)
    attributes[:member] = if attributes['shortname'].present?
                            Shortname.find_resource(attributes.delete('shortname')).profile
                          elsif attributes[:member].present?
                            attributes[:member]
                          else
                            options.fetch(:creator)
                          end
    attributes[:start_date] ||= DateTime.current
    super
  end

  private

  def after_save
    if resource.member.profileable.is_a?(User)
      forum_edge_ids = resource.grants.joins(:edge).where(edges: {owner_type: 'Forum'}).pluck('edges.id').uniq
      if forum_edge_ids.empty? && resource.grants.joins(:edge).where(edges: {owner: resource.page}).present?
        forum_edge_ids = resource.page.edge.children.where(owner_type: 'Forum').pluck(:id)
      end
      forum_edge_ids.each do |forum_edge_id|
        Favorite.create(user: resource.member.profileable, edge_id: forum_edge_id)
      end
    end
    super
  end

  def object_attributes=(obj); end
end
