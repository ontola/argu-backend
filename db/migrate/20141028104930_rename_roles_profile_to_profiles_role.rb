class RenameRolesProfileToProfilesRole < ActiveRecord::Migration
  def change
    rename_table :roles_profiles, :profiles_roles
  end
end
