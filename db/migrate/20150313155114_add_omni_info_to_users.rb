class AddOmniInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :omni_info, :text
  end
end
