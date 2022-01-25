class CreateEdges < ActiveRecord::Migration[7.0]
  def change
    add_column :edges, :cached_properties, :json, default: {}, null: false

    Edge.cache_properties
  end
end
