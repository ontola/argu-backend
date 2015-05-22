class ChangeTimeZoneOnUsers < ActiveRecord::Migration
  def change
    change_column :users, :timezone, :string, default: 'UTC'
    rename_column :users, :timezone, :time_zone
  end
end
