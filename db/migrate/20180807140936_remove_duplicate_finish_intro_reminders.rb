class RemoveDuplicateFinishIntroReminders < ActiveRecord::Migration[5.2]
  def change
    before = Notification.count
    has_duplicates = User.joins(:notifications).where(notifications: {notification_type: 5}).group('users.id').having('count(user_id) > 1')
    count = has_duplicates.count.values.sum - has_duplicates.count.count
    has_duplicates.each do |user|
      first = user.notifications.finish_intro.first
      user.notifications.finish_intro.where('id != ?', first.id).delete_all
      user.sync_notification_count
    end
    expected = before - count
    raise("Expected #{expected} but found #{Notification.count}") unless Notification.count == expected
  end
end
