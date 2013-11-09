class StatementTagUniqueIndex < ActiveRecord::Migration
  def up
    change_column :statements, :tag_id, :integer, unique: true
    add_index :statements, [:tag_id]
  end

  def down
    change_column :statements, :tag_id, :integer, unique: false
    remove_index :statements, [:tag_id]
  end
end
