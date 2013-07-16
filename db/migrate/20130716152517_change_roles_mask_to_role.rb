class ChangeRolesMaskToRole < ActiveRecord::Migration
  def up
  	change_table :users do |t|
	 t.remove :roles_mask
	 t.string :role
	end

	User.all.each do |u|
		u.role = "user"
		u.save
	end
  end

  def down
  	change_table :users do |t|
	 t.integer :roles_mask
	 t.remove :role
	end
  end
end
