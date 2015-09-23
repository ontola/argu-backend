class ChangeNotificationProfileToUser < ActiveRecord::Migration
  def up
    rename_column :notifications, :profile_id, :user_id

    Notification.find_each do |n|
      u = Profile.find(n.user_id).profileable
      n.update_column(:user_id, u.id) if u.is_a? User
    end

    add_foreign_key :notifications, :users, on_delete: :cascade
  end
end
