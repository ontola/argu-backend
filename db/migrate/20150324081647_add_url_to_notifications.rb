class AddUrlToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :url, :string
  end

  def down
    remove_column :notifications, :url
  end
end
