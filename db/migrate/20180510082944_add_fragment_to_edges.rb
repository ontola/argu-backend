class AddFragmentToEdges < ActiveRecord::Migration[5.1]
  def up
    add_column :edges, :fragment, :integer

    Edge.unscoped.roots.each do |root|
      Edge
        .connection
        .execute("WITH row_query AS (SELECT id, ROW_NUMBER() OVER (ORDER BY nlevel(path)) AS row FROM edges WHERE edges.path <@ '#{root.id}') UPDATE edges SET fragment = row_query.row FROM row_query WHERE edges.id = row_query.id;")
    end

    change_column_null :edges, :fragment, false

    add_index :edges, [:root_id, :fragment], unique: true
  end

  def down
    remove_column :edges, :fragment, :integer
  end
end
