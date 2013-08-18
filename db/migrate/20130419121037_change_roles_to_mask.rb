class ChangeRolesToMask < ActiveRecord::Migration
  def up
  	change_table :users do |t|
  		t.integer :roles_mask
  	end
  	drop_table :roles
  	drop_table :roles_users

  	User.where('id > 0').find_in_batches do |group|
  		sleep(50)
  		group.each { |u| u.roles = ["user"] }
  	end
  end

  def down
  end
end
