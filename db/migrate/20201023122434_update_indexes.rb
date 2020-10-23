class UpdateIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_column :edges, :owner_id, :integer
    add_index :edges, :owner_type
    add_index :edges, :is_published
    add_index :edges, :trashed_at

    add_index :activities, :created_at

    add_index :grants, :grant_set_id

    add_index :grant_sets_permitted_actions, :grant_set_id
    add_index :grant_sets_permitted_actions, :permitted_action_id

    add_index :permitted_actions, :action
    add_index :permitted_actions, :resource_type
    add_index :permitted_actions, :parent_type

    add_index :users, :show_feed
  end
end
