class AddWhereToUniqGroupMembershipConstraint < ActiveRecord::Migration[5.1]
  def change
    remove_exclude_constraint :group_memberships, :group_memberships_exclude_overlapping
    add_exclude_constraint :group_memberships, :group_memberships_exclude_overlapping, using: :gist, group_id: :equals, member_id: :equals, 'tsrange(start_date, end_date)' => :overlaps, where: 'member_id != 0'
  end
end
