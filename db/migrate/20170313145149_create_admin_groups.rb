class CreateAdminGroups < ActiveRecord::Migration[5.0]
  def up
    Page.find_each do |page|
      group = Group.new(
        name: 'Admins',
        name_singular: 'Admin',
        page: page,
        deletable: false
      )
      group.grants << Grant.new(role: Grant.roles[:super_admin], edge: page.edge)
      group.edge = Edge.new(user: page.owner.profileable, parent: page.edge)
      group.save!

      service = CreateGroupMembership.new(
        group.edge,
        attributes: {member: page.owner, profile: page.owner},
        options: {publisher: page.owner.profileable, creator: page.owner}
      )
      service.on(:create_group_membership_failed) do |gm|
        raise gm.errors.full_messages
      end
      service.commit
    end
    Rule.where(role: 'owner').update_all(role: 'super_admin')
  end

  def down
    Group.joins(:grants).where(grants: {role: :admin}).destroy_all
  end
end
