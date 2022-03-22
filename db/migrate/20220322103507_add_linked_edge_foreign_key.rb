class AddLinkedEdgeForeignKey < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :properties, :edges, column: :edge_id, primary_key: :uuid
    add_foreign_key :properties, :edges, column: :linked_edge_id, primary_key: :uuid
  end
end
