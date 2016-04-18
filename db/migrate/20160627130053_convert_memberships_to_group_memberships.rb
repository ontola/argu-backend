class ConvertMembershipsToGroupMemberships < ActiveRecord::Migration
  def up
    change_column_null :group_memberships, :group_id, false
    change_column_null :group_memberships, :member_id, false
    change_column_null :groups, :forum_id, true

    add_column :groups, :shortname, :string
    add_column :groups, :edge_id, :integer
    Group.find_each do |group|
      group.set_shortname
      group.edge = Edge.where(owner_id: group.forum_id, owner_type: 'Forum').first
      group.save
    end
    change_column_null :groups, :shortname, false
    change_column_null :groups, :edge_id, false

    Forum.find_each do |f|
      f.edge.build_default_groups
      f.edge.save
    end
    Page.find_each do |p|
      p.edge.build_default_groups
      p.edge.save
    end

    Membership.find_each do |m|
      group = m.manager? ? m.forum.managers_group : m.forum.members_group
      GroupMembership.create(group: group, member: m.profile, profile: m.profile)
    end

    PageMembership.find_each do |m|
      group = m.manager? ? m.page.managers_group : m.page.members_group
      GroupMembership.create(group: group, member: m.profile, profile: m.profile)
    end

    add_index :groups, [:edge_id, :shortname], unique: true
    add_foreign_key :groups, :forums
    add_foreign_key :groups, :edges
    add_foreign_key :group_memberships, :groups
    add_foreign_key :group_memberships, :profiles
    add_foreign_key :group_memberships, :profiles, column: :member_id
  end

  def down
    change_column_null :group_memberships, :group_id, true
    change_column_null :group_memberships, :member_id, true

    Forum.find_each do |forum|
      forum.managers_group.destroy
      forum.members_group.destroy
    end
    Page.find_each do |forum|
      forum.managers_group.destroy
      forum.members_group.destroy
    end

    add_column :groups, :forum_id, :integer
    Group.find_each do |group|
      group.update(forum_id: edge.forum_id)
    end
    change_column_null :groups, :forum_id, false

    remove_column :groups, :shortname
    remove_column :groups, :edge_id

    remove_foreign_key :groups, :forums
    remove_foreign_key :group_memberships, :groups
    remove_foreign_key :group_memberships, :profiles
    remove_foreign_key :group_memberships, column: :member_id
  end
end
