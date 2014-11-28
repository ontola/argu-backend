class ReverseProfileRelation < ActiveRecord::Migration
  def change
    remove_column :profiles, :user_id
    add_column :users, :profile_id, :integer
    add_column :pages, :profile_id, :integer
  end
end
