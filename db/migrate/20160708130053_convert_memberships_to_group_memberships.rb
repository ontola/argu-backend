class ConvertMembershipsToGroupMemberships < ActiveRecord::Migration
  def up
    change_column_null :group_memberships, :group_id, false
    change_column_null :group_memberships, :member_id, false
    change_column_null :groups, :forum_id, true

    add_column :groups, :page_id, :integer
    add_foreign_key :groups, :pages
    add_foreign_key :groups, :forums
    add_foreign_key :group_memberships, :groups
    add_foreign_key :group_memberships, :profiles
    add_foreign_key :group_memberships, :profiles, column: :member_id

    create_table :grants do |t|
      t.integer :group_id, null: false
      t.integer :edge_id, null: false
      t.integer :role, default: 0, null: false
      t.timestamps null: false
    end
    add_foreign_key :grants, :groups
    add_foreign_key :grants, :edges

    Group.find_each do |group|
      page = Forum.find(group[:forum_id]).page
      group.page = page
      group.create_edge!(
        parent: page.edge,
        user: group.publisher,
        created_at: group.created_at,
        updated_at: group.updated_at)
      group.save!
    end
    change_column_null :groups, :page_id, false

    GroupMembership.find_each do |group_membership|
      group_membership.create_edge!(
        parent: group_membership.group.edge,
        user: group_membership.profile.profileable,
        created_at: group_membership.created_at,
        updated_at: group_membership.updated_at)
    end

    before_count = Group.count
    Page.find_each do |p|
      p.create_default_groups
    end
    raise "Group count #{Group.count} should be #{before_count + (Page.count * 2)}" unless Group.count == before_count + (Page.count * 2)

    PageMembership.find_each do |m|
      role = m.manager? ? Grant.roles[:manager] : Grant.roles[:member]
      group = m.page.edge.groups.where(grants: {role: role}).first
      user = m.profile.profileable.is_a?(User) ? m.profile.profileable : m.profile.profileable.owner.profileable
      service = CreateGroupMembership.new(
        group.edge,
        attributes: {member: m.profile},
        options: {creator: user.profile, publisher: user})
      service.on(:create_group_membership_failed) { raise "Converting PageMembership #{m.id} failed" }
      service.commit
    end

    before_count = Group.count
    Forum.find_each do |f|
      f.create_default_groups
    end
    raise "Group count #{Group.count} should be #{before_count + (Forum.count * 2)}" unless Group.count == before_count + (Forum.count * 2)

    Membership.find_each do |m|
      role = m.manager? ? Grant.roles[:manager] : Grant.roles[:member]
      group = m.forum.edge.groups.where(grants: {role: role}).first
      user = m.profile.profileable.is_a?(User) ? m.profile.profileable : m.profile.profileable.owner.profileable
      service = CreateGroupMembership.new(
        group.edge,
        attributes: {member: m.profile},
        options: {creator: user.profile, publisher: user})
      service.on(:create_group_membership_failed) { raise "Converting Membership #{m.id} failed" }
      service.commit
    end

    Follow.counter_culture_fix_counts.each do |result|
      puts "#{result[:entity].constantize.find(result[:id]).display_name}: #{result[:what]} is set to #{result[:right]} (was #{result[:wrong]})"
    end
  end

  def down
    change_column_null :group_memberships, :group_id, true
    change_column_null :group_memberships, :member_id, true

    Group.find_each do |group|
      group.edge.destroy!
    end
    GroupMembership.find_each do |group_membership|
      group_membership.edge.destroy!
    end
    Forum.find_each do |forum|
      forum.managers_group.destroy!
      forum.members_group.destroy!
    end
    Page.find_each do |forum|
      forum.managers_group.destroy!
      forum.members_group.destroy!
    end

    change_column_null :groups, :forum_id, false

    remove_column :groups, :page_id

    drop_table :grants

    remove_foreign_key :groups, :forums
    remove_foreign_key :group_memberships, :groups
    remove_foreign_key :group_memberships, :profiles
    remove_foreign_key :group_memberships, column: :member_id
  end
end
