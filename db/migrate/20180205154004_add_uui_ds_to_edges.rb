class AddUuiDsToEdges < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
  end
end
