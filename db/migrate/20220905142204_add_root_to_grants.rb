class AddRootToGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :grants, :root_id, :uuid
    add_index :grants, :root_id
    add_index :grants, %i[root_id edge_id]
    add_index :grants, %i[root_id group_id]

    Grant.connection.update('UPDATE grants SET root_id = edges.root_id FROM edges WHERE edges.uuid = grants.edge_id')

    change_column_null :grants, :root_id, false

    add_foreign_key :group_memberships, :edges, column: :root_id, primary_key: :uuid
    add_foreign_key :grants, :edges, column: :root_id, primary_key: :uuid
  end
end
