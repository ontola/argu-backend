class AddGroupIdRoleUniqueIndex < ActiveRecord::Migration[5.0]
  def up
    remove_index :grants, [:group_id, :edge_id, :role]
    add_index :grants, [:group_id, :edge_id], unique: true
  end
end
