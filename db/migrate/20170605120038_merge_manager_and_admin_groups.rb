class MergeManagerAndAdminGroups < ActiveRecord::Migration[5.0]
  def up
    Page.find_each do |page|
      managers_group = page.grants.manager.first.group
      admins_group = page.grants.super_admin.first.group
      managers_group
        .group_memberships
        .where('member_id NOT IN (?)', admins_group.group_memberships.pluck(:member_id))
        .update_all(group_id: admins_group.id)
      Decision.where(forwarded_group_id: managers_group.id).update_all(forwarded_group_id: admins_group.id)
      managers_group.destroy!
    end
    Group
      .joins(grants: :edge)
      .where(grants: {role: :super_admin}, edges: {owner_type: 'Page'})
      .update_all(name: 'Admins', name_singular: 'Admin')
  end
end
