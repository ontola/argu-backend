class RenameMembersCountToMembershipsCount < ActiveRecord::Migration
  def change
    rename_column :organisations, :members_count, :memberships_count
  end
end
