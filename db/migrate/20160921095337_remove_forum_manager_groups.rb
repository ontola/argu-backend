class RemoveForumManagerGroups < ActiveRecord::Migration[5.0]
  def up
    # Remove the managers of all forums of page 'Argu'
    Page.find_via_shortname('argu').forums.each do |forum|
      forum.grants.manager.includes(group: :members).first.group.group_memberships.destroy_all
    end

    # Add all forum managers to managers group of its page
    Page.all.each do |page|
      page.forums.each do |forum|
        forum_group = forum.grants.manager.includes(group: :members).first.group
        page_group = page.grants.manager.includes(group: :members).first.group
        (forum_group.members - page_group.members).each do |member|
          GroupMembership.create(group: page_group, profile: member, edge: Edge.new(parent: page_group.edge))
        end
      end
    end

    # Remove Forum.managers_group and Page.members_group
    Group.where(id: Grant.forum_manager.pluck(:group_id)).destroy_all
    Group.where(id: Grant.page_member.pluck(:group_id)).destroy_all
  end
end
