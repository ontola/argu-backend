class AddActivityConstraintToNotifications < ActiveRecord::Migration
  def change
    add_foreign_key :notifications, :activities
  end
end
