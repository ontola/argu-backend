class AddRootToEdges < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :root_id, :uuid
    Edge.reset_column_information
    Edge.unscoped.roots.each do |root|
      root.self_and_descendants.update_all(root_id: root.uuid)
    end
    change_column_null :edges, :root_id, false
  end
end
