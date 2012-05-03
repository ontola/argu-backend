class AddUserTypeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :clearance, :int
  end
end
