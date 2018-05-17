class ConvertAdditionalForeignKeys < ActiveRecord::Migration[5.1]
  def change
    change_foreign_key(:grant_sets, :page_id, true, 'Page')
    change_foreign_key(:groups, :page_id, false, 'Page')

    add_index :grant_sets, [:title, :page_id], unique: true

    change_foreign_key(:activities, :forum_id, true, 'Forum')
    change_foreign_key(:banners, :forum_id, true, 'Forum')
    change_foreign_key(:media_objects, :forum_id, true, 'Forum')
    change_foreign_key(:placements, :forum_id, true, 'Forum')

    add_index :activities, [:forum_id, :owner_id, :owner_type]
    add_index :activities, [:forum_id, :trackable_id, :trackable_type], name: 'forum_trackable'
    add_index :activities, :forum_id

    add_index :banners, [:forum_id, :published_at]
    add_index :banners, :forum_id

    add_index :media_objects, :forum_id
    add_index :placements, :forum_id
  end

  private

  def change_foreign_key(table, column, allow_null, type)
    puts "Processing #{table}"

    old_column = "old_#{column}"
    rename_column table, column, old_column
    add_column table, column, :uuid

    ActiveRecord::Base.connection.update("UPDATE #{table} SET #{column} = edges.uuid FROM edges WHERE edges.owner_id = #{table}.#{old_column} AND edges.owner_type = '#{type}'")

    remove_column table, old_column
    change_column_null table, column, allow_null

    add_foreign_key table, :edges, column: column, primary_key: :uuid
  end
end
