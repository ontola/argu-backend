class ProfilesRole < ActiveRecord::Migration
  def change
    create_table :profiles_roles do |t|
      t.integer :profile_id
      t.integer :role_id
      t.timestamps
    end
    add_index :profiles_roles, [:profile_id, :role_id]
  end
end
