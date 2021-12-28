class AddIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :group_memberships, %i[start_date end_date]
    add_index :group_memberships, %i[start_date end_date group_id member_id], name: :index_group_memberships_full
    add_index :permitted_actions, %i[action_name resource_type]
    add_index :shortnames, %i[owner_id primary]
  end
end
