class AddCreatedAtIndexToActivities < ActiveRecord::Migration[5.2]
  def change
    add_index :grants, :group_id
    add_index :edges, [:root_id, :path]
    add_index :edges, :path, using: :gist
  end
end
