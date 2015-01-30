class AddRFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :r, :text
  end
end
