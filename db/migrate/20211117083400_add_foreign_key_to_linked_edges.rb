class AddForeignKeyToLinkedEdges < ActiveRecord::Migration[6.1]
  def change
    Property
      .joins('LEFT JOIN edges ON edges.uuid = properties.linked_edge_id')
      .where('properties.linked_edge_id IS NOT NULL AND edges.uuid IS NULL')
      .update_all(linked_edge_id: nil)

    add_foreign_key :properties, :edges, column: :linked_edge_id, primary_key: :uuid
  end
end
