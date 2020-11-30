class AddIndexToProperties < ActiveRecord::Migration[6.0]
  def change
    add_index :properties, %i[root_id edge_id]
    add_index :properties, %i[edge_id predicate integer]
    add_index :properties, %i[root_id edge_id linked_edge_id predicate order], name: :order_index
  end
end
