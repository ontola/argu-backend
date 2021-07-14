class AddSessionIdToEdges < ActiveRecord::Migration[6.0]
  def change
    add_column :edges, :session_id, :string
  end
end
