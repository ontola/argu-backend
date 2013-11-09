class AddTagIdToStatement < ActiveRecord::Migration
  def up
    add_column :statements, :tag_id, :integer
  end

  def down
    remove_column :statements, :tag_id
  end
end
