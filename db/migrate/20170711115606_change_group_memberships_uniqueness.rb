class ChangeGroupMembershipsUniqueness < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS btree_gist;'
    remove_index :group_memberships, column: [:group_id, :member_id]
    add_exclude_constraint :group_memberships, :group_memberships_exclude_overlapping, using: :gist, group_id: :equals, member_id: :equals, 'tsrange(start_date, end_date)' => :overlaps
  end

  def down
    add_index :group_memberships, [:group_id, :member_id], unique: true
    remove_exclude_constraint :group_memberships, :group_memberships_exclude_overlapping, using: :gist, group_id: :equals, member_id: :equals, 'tsrange(start_date, end_date)' => :overlaps
  end
end
