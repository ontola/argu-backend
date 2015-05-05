class AddHasAnalyticsFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_analytics, :boolean, default: true
  end
end
