class DropGroupMembershipsProfileId < ActiveRecord::Migration[5.1]
  def change
    remove_column :group_memberships, :profile_id
  end
end
