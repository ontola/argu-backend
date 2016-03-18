class RefactorRelationsToProfile < ActiveRecord::Migration
  def change
    rename_column :comments, :user_id, :profile_id
    rename_column :group_memberships, :user_id, :profile_id
    rename_column :memberships, :user_id, :profile_id
    rename_column :users_roles, :user_id, :profile_id
    rename_table :users_roles, :roles_profiles
  end
end
