class UsersNotificationsViewedAt < ActiveRecord::Migration
  def up
    add_column :users, :notifications_viewed_at, :datetime
  end

  def down
    remove_column :users, :notifications_viewed_at
  end
end
