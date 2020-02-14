class AddRootIdToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :root_id, :uuid
    add_index  :properties, :root_id

    Property.connection.update('UPDATE properties SET root_id = edges.root_id FROM edges WHERE edges.uuid = properties.edge_id')

    change_column_null  :properties, :root_id, false
  end
end
