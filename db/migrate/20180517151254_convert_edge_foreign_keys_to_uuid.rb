class ConvertEdgeForeignKeysToUUID < ActiveRecord::Migration[5.1]
  def change
    remove_column :publications, :publishable_type

    change_foreign_key(:activities, :trackable_edge_id, true)
    change_foreign_key(:activities, :recipient_edge_id, true)
    change_foreign_key(:favorites, :edge_id, false)
    change_foreign_key(:follows, :followable_id, false)
    change_foreign_key(:grants, :edge_id, false)
    change_foreign_key(:grant_resets, :edge_id, false)
    change_foreign_key(:publications, :publishable_id, true)
    change_foreign_key(:exports, :edge_id, false)

    add_index :favorites, %i[user_id edge_id], unique: true
    add_index :follows, %i[follower_type follower_id followable_type followable_id], unique: true, name: 'index_follower_followable'
    add_index :follows, %i[followable_type followable_id]
    add_index :grant_resets, %i[edge_id resource_type action], unique: true
    add_index :grants, %i[group_id edge_id], unique: true
  end

  private

  def change_foreign_key(table, column, allow_null)
    puts "Processing #{table}"

    old_column = "old_#{column}"
    rename_column table, column, old_column
    add_column table, column, :uuid

    ActiveRecord::Base.connection.update("UPDATE #{table} SET #{column} = edges.uuid FROM edges WHERE edges.id = #{table}.#{old_column}")

    remove_column table, old_column
    change_column_null table, column, allow_null

    add_foreign_key table, :edges, column: column, primary_key: :uuid
  end
end
