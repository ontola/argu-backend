class DropRoles < ActiveRecord::Migration[5.1]
  def up
    drop_table :profiles_roles
    drop_table :roles
  end
end
