class AddNotificationsFieldsToUser < ActiveRecord::Migration
  def up
    add_column :users, :follows_email, :integer, null: false, default: 1
    add_column :users, :follows_mobile, :boolean, null: false, default: true

    add_column :users, :memberships_email, :integer, null: false, default: 1
    add_column :users, :memberships_mobile, :boolean, null: false, default: true

    add_column :users, :created_email, :integer, null: false, default: 1
    add_column :users, :created_mobile, :boolean, null: false, default: true
  end
  def down
    remove_column :users, :follows_email
    remove_column :users, :follows_mobile
    remove_column :users, :memberships_email
    remove_column :users, :memberships_mobile
    remove_column :users, :created_email
    remove_column :users, :created_mobile
  end
end
