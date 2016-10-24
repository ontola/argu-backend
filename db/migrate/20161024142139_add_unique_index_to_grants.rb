class AddUniqueIndexToGrants < ActiveRecord::Migration[5.0]
  def up
    add_index :grants, [:group_id, :edge_id, :role], unique: true
  end

  def down
    remove_index :grants, [:group_id, :edge_id, :role]
  end
end
