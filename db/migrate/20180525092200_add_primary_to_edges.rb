class AddPrimaryToEdges < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :primary, :boolean

    Edge.connection.update('UPDATE edges SET "primary" = votes.primary FROM votes WHERE votes.id = edges.owner_id AND edges.owner_type = \'Vote\'')

    add_index :edges, [:parent_id, :creator_id], unique: true, where: "(\"primary\" IS TRUE)"
  end
end
