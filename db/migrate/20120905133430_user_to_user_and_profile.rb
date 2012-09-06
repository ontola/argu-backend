class UserToUserAndProfile < ActiveRecord::Migration
  def up
  	create_table :profiles do |t|
      t.integer :user_id
  		t.string :name
  		t.text :about
  		t.string :picture
  		t.timestamps
  	end
  	remove_column :users, :name
  end

  def down
  	drop_table :profiles
  	add_column :users, :name, :string
  end
end
