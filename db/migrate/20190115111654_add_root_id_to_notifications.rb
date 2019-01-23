class AddRootIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    Notification.reaction.where(activity_id: nil).destroy_all

    add_column :notifications, :root_id, :uuid
    add_index :notifications, :root_id
    add_foreign_key :notifications, :edges, primary_key: :uuid, column: :root_id

    Notification.connection.update("UPDATE notifications SET root_id = activities.root_id FROM activities WHERE activities.id = notifications.activity_id")
    Notification.connection.update("UPDATE notifications SET root_id = edges.root_id FROM edges WHERE edges.publisher_id = notifications.user_id AND notifications.root_id IS NULL")

    Notification.where(root_id: nil).update_all(root_id: Page.find_via_shortname('nederland').uuid)

    change_column_null :notifications, :root_id, false
  end
end
