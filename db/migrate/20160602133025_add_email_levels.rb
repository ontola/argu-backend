class AddEmailLevels < ActiveRecord::Migration
  def up
    add_column :follows, :follow_type, :integer, default: 30, null: false
    add_column :notifications, :notification_type, :integer
    add_column :users, :decisions_email, :integer, default: 3, null: false
    add_column :users, :news_email, :integer, default: 3, null: false
    add_column :users, :reactions_email, :integer, default: 3, null: false

    User.update_all('reactions_email=follows_email')
    Notification.update_all(notification_type: Notification.notification_types[:reaction])
    change_column_null :notifications, :notification_type, false

    Follow.find_each do |follow|
      follow
        .followable
        .ancestors
        .where(owner_type: ['Motion', 'Question', 'Project'])
        .each do |ancestor|
          current_follow_type = follow
                                  .followable
                                  .owner
                                  .publisher
                                  .following_type(ancestor)
          if Follow.follow_types[:news] > Follow.follow_types[current_follow_type]
            follow
              .followable
              .owner
              .publisher
              .follow(ancestor, :news)
          end
      end
    end
  end

  def down
    Follow.where.not(follow_type: 30).destroy_all

    remove_column :follows, :follow_type
    remove_column :notifications, :notification_type
    remove_column :users, :decisions_email
    remove_column :users, :news_email
    remove_column :users, :reactions_email
  end
end
