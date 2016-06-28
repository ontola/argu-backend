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

    destroy_orphan_edges

    Vote.includes(:edge, :publisher).find_each { |vote| vote.publisher.follow(vote.edge, nil, :news) }

    Follow.includes(:followable).find_each do |follow|
      follow
        .followable
        .ancestors
        .where(owner_type: %w(Motion Question Project))
        .each do |ancestor|
          current_follow_type = follow.follower.following_type(ancestor)
          if Follow.follow_types[:news] > Follow.follow_types[current_follow_type]
            follow.follower.follow(ancestor, :news)
          end
      end
    end
  end

  def down
    Follow.where.not(follow_type: Follow.follow_types[:reactions]).destroy_all

    remove_column :follows, :follow_type
    remove_column :notifications, :notification_type
    remove_column :users, :decisions_email
    remove_column :users, :news_email
    remove_column :users, :reactions_email
  end

  private

  def destroy_orphan_edges
    Edge
      .pluck(:owner_type)
      .uniq
      .map do |klass|
        table = klass.underscore.pluralize
        orphans = Edge.joins("LEFT JOIN #{table} ON edges.owner_id = #{table}.id WHERE owner_type = '#{klass}' AND #{table}.id IS NULL")
        if orphans.present?
          puts "Destroying #{orphans.count} edges of type #{klass}"
          orphans.destroy_all
        end
      end
  end
end
