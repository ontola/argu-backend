class AddConstraintsToMemberships < ActiveRecord::Migration
  def change
    change_column :memberships, :profile_id, :integer, null: false
    change_column :memberships, :forum_id, :integer, null: false
  end
end
