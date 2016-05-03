class AddForumIdToShortnames < ActiveRecord::Migration
  def up
    add_column :forums, :max_shortname_count, :integer, default: 0, null: false
    add_column :shortnames, :forum_id, :integer
    add_foreign_key :shortnames, :forums
  end

  def down
    remove_column :forums, :max_shortname_count
    remove_column :shortnames, :forum_id
  end
end
