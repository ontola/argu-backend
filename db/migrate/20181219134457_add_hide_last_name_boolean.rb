class AddHideLastNameBoolean < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :hide_last_name, :boolean, default: false
  end
end
