class AddStaffBool < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :staff, :boolean, default: false, null: false

    User.joins(profile: :group_memberships).where(group_memberships: {group_id: -2}).update_all(staff: true)
    Grant.where(group_id: -2).delete_all
  end
end
