class AddForumIdToNotifications < ActiveRecord::Migration
  def up
    add_reference :notifications, :forum, index: true
    add_foreign_key :notifications, :forums, dependent: :delete
  end

  def down
    remove_column :notifications, :forum_id
  end
end
