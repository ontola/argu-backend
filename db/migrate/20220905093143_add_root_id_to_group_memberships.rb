class AddRootIdToGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :group_memberships, :root_id, :uuid
    add_index :group_memberships, :root_id
    add_index :group_memberships, %i[root_id group_id]
    add_index :group_memberships, %i[root_id start_date end_date]

    GroupMembership.connection.update('UPDATE group_memberships SET root_id = groups.root_id FROM groups WHERE groups.id = group_memberships.group_id')

    change_column_null :group_memberships, :root_id, false
  end
end
