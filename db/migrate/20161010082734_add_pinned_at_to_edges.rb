class AddPinnedAtToEdges < ActiveRecord::Migration[5.0]
  def change
    add_column :edges, :pinned_at, :datetime
  end
end
